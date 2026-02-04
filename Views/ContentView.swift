import SwiftUI

struct ContentView: View {

    @StateObject private var viewModel = WeatherViewModel()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {

                    // City input
                    TextField("Enter city", text: $viewModel.cityName)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                        .onChange(of: viewModel.cityName) {
                            viewModel.fetchSuggestions()
                        }

                    // Suggestions
                    if !viewModel.suggestions.isEmpty {
                        VStack(alignment: .leading) {
                            ForEach(viewModel.suggestions) { city in
                                Text("\(city.name), \(city.country)")
                                    .padding(6)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.gray.opacity(0.15))
                                    .cornerRadius(6)
                                    .onTapGesture {
                                        viewModel.cityName = city.name
                                        viewModel.suggestions = []
                                    }
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Search button
                    Button("Search") {
                        viewModel.searchWeather()
                    }
                    .buttonStyle(.borderedProminent)

                    // Settings — Fahrenheit / Celsius
                    Toggle("Use Fahrenheit (°F)", isOn: $viewModel.useFahrenheit)
                        .padding(.horizontal)
                        .onChange(of: viewModel.useFahrenheit) {
                            viewModel.searchWeather()
                        }

                    // Error message
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }

                    // Weather info
                    VStack(spacing: 6) {
                        Text(viewModel.cityName)
                            .font(.title2)
                            .bold()

                        Text(viewModel.temperature)
                            .font(.largeTitle)
                            .bold()

                        Text("Condition: \(viewModel.condition)")
                        Text("Humidity: \(viewModel.humidity)")
                        Text("Feels like: \(viewModel.feelsLike)")
                        Text("Wind: \(viewModel.wind)")
                        Text("Last update: \(viewModel.lastUpdate)")
                            .font(.caption)
                            .foregroundColor(.gray)

                        if viewModel.isOffline {
                            Text("Offline mode")
                                .foregroundColor(.orange)
                                .font(.caption)
                        }
                    }
                    .padding()

                    // Hourly forecast
                    if !viewModel.hourlyForecast.isEmpty {
                        Text("Hourly Forecast (24h)")
                            .font(.headline)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(viewModel.hourlyForecast) { hour in
                                    VStack {
                                        Text(hour.time.prefix(16))
                                            .font(.caption)
                                        Text("\(hour.temperature, specifier: "%.1f")°C")
                                    }
                                    .padding()
                                    .background(Color.gray.opacity(0.15))
                                    .cornerRadius(10)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Weather App")
        }
    }
}
