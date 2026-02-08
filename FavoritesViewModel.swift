import Foundation
import Combine

@MainActor
final class FavoritesViewModel: ObservableObject {

    @Published var cities: [FavoriteCity] = []
    @Published var weatherByCity: [String: String] = [:]

    private let repo: FavoritesRepository
    private let weatherService = WeatherAPIService()

    init(uid: String) {
        self.repo = FavoritesRepository(uid: uid)

        repo.observeCities { [weak self] (cities: [FavoriteCity]) in
            guard let self else { return }
            self.cities = cities
            self.loadWeatherForFavorites(cities)
        }
    }

    // MARK: - CRUD

    func addCity(name: String, note: String) {
        // защита от дублей
        guard !cities.contains(where: {
            $0.name.lowercased() == name.lowercased()
        }) else { return }

        repo.addCity(name: name, note: note)
    }

    func deleteCity(id: String) {
        repo.deleteCity(id: id)
    }

    func updateCity(id: String, name: String, note: String) {
        repo.updateCity(id: id, name: name, note: note)
    }

    // MARK: - Weather for favorites

    private func loadWeatherForFavorites(_ cities: [FavoriteCity]) {
        for city in cities {
            fetchWeather(for: city.name)
        }
    }

    private func fetchWeather(for cityName: String) {
        weatherService.fetchCoordinates(for: cityName) { [weak self] result in
            guard let self else { return }

            if case .success(let location) = result {
                self.weatherService.fetchCurrentWeather(
                    latitude: location.latitude,
                    longitude: location.longitude
                ) { weatherResult in
                    if case .success(let weather) = weatherResult {
                        DispatchQueue.main.async {
                            self.weatherByCity[cityName] =
                                "\(Int(weather.current_weather.temperature))°C"
                        }
                    }
                }
            }
        }
    }
}
