import Foundation
import Combine

@MainActor
class WeatherViewModel: ObservableObject {

    @Published var cityName: String = ""
    @Published var suggestions: [GeocodingResult] = []

    @Published var temperature = "--"
    @Published var condition = "--"
    @Published var humidity = "--"
    @Published var feelsLike = "--"
    @Published var wind = "--"
    @Published var lastUpdate = "--"

    @Published var hourlyForecast: [HourlyWeather] = []

    @Published var errorMessage: String?
    @Published var isOffline = false

    @Published var useFahrenheit = false

    private let service = WeatherAPIService()
    private let cacheKey = "cached_weather"

    func fetchSuggestions() {
        let trimmed = cityName.trimmingCharacters(in: .whitespacesAndNewlines)

        guard trimmed.count >= 2 else {
            suggestions = []
            return
        }

        service.fetchCoordinatesList(for: trimmed) { result in
            DispatchQueue.main.async {
                if case .success(let cities) = result {
                    self.suggestions = cities
                }
            }
        }
    }

    func searchWeather() {
        errorMessage = nil

        let trimmedCity = cityName.trimmingCharacters(in: .whitespacesAndNewlines)

        // Empty input
        guard !trimmedCity.isEmpty else {
            errorMessage = "Please enter a city name"
            isOffline = false
            return
        }

        service.fetchCoordinatesList(for: trimmedCity) { result in
            DispatchQueue.main.async {
                switch result {

                // City not found
                case .success(let cities):
                    guard let city = cities.first else {
                        self.errorMessage = "City not found"
                        self.isOffline = false
                        return
                    }

                    self.cityName = city.name
                    self.suggestions = []
                    self.isOffline = false

                    self.fetchWeather(lat: city.latitude, lon: city.longitude)
                    self.fetchHourlyForecast(lat: city.latitude, lon: city.longitude)

                // No internet
                case .failure:
                    self.errorMessage = "Offline mode"
                    self.isOffline = true
                    self.loadFromCache()
                }
            }
        }
    }


    private func fetchWeather(lat: Double, lon: Double) {
        service.fetchCurrentWeather(latitude: lat, longitude: lon) { result in
            DispatchQueue.main.async {
                switch result {

                case .success(let response):
                    let current = response.current_weather

                    let tempC = current.temperature
                    let feelsC = response.hourly?.apparent_temperature.first ?? current.temperature

                    let temp = self.useFahrenheit ? self.celsiusToFahrenheit(tempC) : tempC
                    let feels = self.useFahrenheit ? self.celsiusToFahrenheit(feelsC) : feelsC
                    let unit = self.useFahrenheit ? "°F" : "°C"

                    self.temperature = "\(String(format: "%.1f", temp)) \(unit)"
                    self.feelsLike = "\(String(format: "%.1f", feels)) \(unit)"
                    self.condition = WeatherCodeMapper.description(for: current.weathercode)
                    self.humidity = "\(Int(response.hourly?.relative_humidity_2m.first ?? 0))%"
                    self.wind = "\(current.windspeed) km/h"
                    self.lastUpdate = current.time

                    self.isOffline = false
                    self.saveToCache()

                case .failure:
                    self.errorMessage = "Offline mode"
                    self.isOffline = true
                    self.loadFromCache()
                }
            }
        }
    }


    private func fetchHourlyForecast(lat: Double, lon: Double) {
        service.fetchHourlyForecast(latitude: lat, longitude: lon) { result in
            DispatchQueue.main.async {
                if case .success(let forecast) = result {
                    self.hourlyForecast = Array(forecast.prefix(24))
                }
            }
        }
    }


    private func saveToCache() {
        let cached = CachedWeather(
            city: cityName,
            temperature: temperature,
            condition: condition,
            humidity: humidity,
            feelsLike: feelsLike,
            wind: wind,
            lastUpdated: lastUpdate
        )

        if let data = try? JSONEncoder().encode(cached) {
            UserDefaults.standard.set(data, forKey: cacheKey)
        }
    }

    private func loadFromCache() {
        guard let data = UserDefaults.standard.data(forKey: cacheKey),
              let cached = try? JSONDecoder().decode(CachedWeather.self, from: data)
        else { return }

        cityName = cached.city
        temperature = cached.temperature
        condition = cached.condition
        humidity = cached.humidity
        feelsLike = cached.feelsLike
        wind = cached.wind
        lastUpdate = cached.lastUpdated
    }

    private func celsiusToFahrenheit(_ value: Double) -> Double {
        value * 9 / 5 + 32
    }
}
