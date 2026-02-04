import Foundation

final class WeatherAPIService {

    func fetchCoordinates(
        for city: String,
        completion: @escaping (Result<GeocodingResult, Error>) -> Void
    ) {
        let urlString =
        "https://geocoding-api.open-meteo.com/v1/search?name=\(city)&count=1"

        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else { return }

            do {
                let decoded = try JSONDecoder().decode(
                    GeocodingResponse.self,
                    from: data
                )

                if let result = decoded.results?.first {
                    completion(.success(result))
                } else {
                    completion(.failure(NSError()))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    func fetchCoordinatesList(
        for query: String,
        completion: @escaping (Result<[GeocodingResult], Error>) -> Void
    ) {
        let urlString =
        "https://geocoding-api.open-meteo.com/v1/search?name=\(query)&count=5"

        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.success([]))
                return
            }

            do {
                let decoded = try JSONDecoder().decode(
                    GeocodingResponse.self,
                    from: data
                )
                completion(.success(decoded.results ?? []))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    func fetchCurrentWeather(
        latitude: Double,
        longitude: Double,
        completion: @escaping (Result<WeatherResponse, Error>) -> Void
    ) {
        let urlString =
        "https://api.open-meteo.com/v1/forecast?latitude=\(latitude)&longitude=\(longitude)&current_weather=true&hourly=relative_humidity_2m,apparent_temperature"

        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else { return }

            do {
                let decoded = try JSONDecoder().decode(WeatherResponse.self, from: data)
                completion(.success(decoded))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }


    func fetchHourlyForecast(
        latitude: Double,
        longitude: Double,
        completion: @escaping (Result<[HourlyWeather], Error>) -> Void
    ) {
        let urlString =
        "https://api.open-meteo.com/v1/forecast?latitude=\(latitude)&longitude=\(longitude)&hourly=temperature_2m"

        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else { return }

            do {
                let decoded = try JSONDecoder().decode(
                    HourlyWeatherResponse.self,
                    from: data
                )

                let hourly = zip(
                    decoded.hourly.time,
                    decoded.hourly.temperature_2m
                ).map { time, temp in
                    HourlyWeather(time: time, temperature: temp)
                }

                completion(.success(hourly))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
