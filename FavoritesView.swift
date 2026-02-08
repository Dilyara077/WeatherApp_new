import SwiftUI

struct FavoritesView: View {

    @StateObject var vm: FavoritesViewModel

    @State private var editingCity: FavoriteCity?
    @State private var editedNote = ""

    init(vm: FavoritesViewModel) {
        _vm = StateObject(wrappedValue: vm)
    }

    var body: some View {
        NavigationView {
            List {

                if vm.cities.isEmpty {
                    Text("No favorites yet")
                        .foregroundColor(.gray)
                }

                ForEach(vm.cities) { city in
                    VStack(alignment: .leading, spacing: 6) {

                        HStack {
                            Text(city.name)
                                .font(.headline)

                            Spacer()

                            Text(vm.weatherByCity[city.name] ?? "--")
                                .foregroundColor(.blue)
                        }

                        Text(city.note)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .onTapGesture {
                        editingCity = city
                        editedNote = city.note
                    }
                }
                .onDelete { indexSet in
                    indexSet.forEach {
                        vm.deleteCity(id: vm.cities[$0].id)
                    }
                }
            }
            .navigationTitle("Favorites")
            .alert("Edit note", isPresented: .constant(editingCity != nil)) {

                TextField("Note", text: $editedNote)

                Button("Save") {
                    if let city = editingCity {
                        vm.updateCity(
                            id: city.id,
                            name: city.name,
                            note: editedNote
                        )
                    }
                    editingCity = nil
                }

                Button("Cancel", role: .cancel) {
                    editingCity = nil
                }
            }
        }
    }
}
