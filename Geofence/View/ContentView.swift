import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: false)],
        animation: .default)

    private var items: FetchedResults<Item>

    @ObservedObject var locationViewModel = LocationViewModel()

    var latitude: String { return("\(locationViewModel.location?.latitude ?? 0)") }
    var longitude: String { return("\(locationViewModel.location?.longitude ?? 0)") }
    var placemark: String { return("\(locationViewModel.placemark?.locality ?? "")") }
    var status: String { return("\(String(describing: locationViewModel.status))") }

    var latitudeFence: String { return("\(locationViewModel.region?.center.latitude ?? 0)") }
    var longitudeFence: String { return("\(locationViewModel.region?.center.longitude ?? 0)") }
    var placemarkFence: String { return("\(locationViewModel.region?.identifier ?? "")") }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Fence: \(self.placemarkFence)")
                    HStack {
                        Text("Lat: \(self.latitudeFence)")
                        Text("Long: \(self.longitudeFence)")
                    }
                    Text("Placemark: \(self.placemark)")
                    HStack {
                        Text("Lat: \(self.latitude)")
                        Text("Long: \(self.longitude)")
                    }
                }.padding(16)
                List {
                    ForEach(items) { item in
                        NavigationLink {
                            VStack(alignment: .leading, spacing: 0) {
                                Text("Event at \(item.timestamp!, formatter: itemFormatter)")
                                Text("Latitude: \(item.latitude)")
                                Text("Longiture: \(item.longitude)")
                                Text("Event: \(item.eventType ?? "")")
                            }
                        } label: {
                            VStack(alignment: .leading, spacing: 0) {
                                Text("Event: \(item.eventType ?? "")")
                                Text(item.timestamp!, formatter: itemFormatter)
                            }
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
            }
            .navigationTitle("Geofence")
            .navigationBarHidden(false)
            .navigationBarTitleDisplayMode(.inline)
        }.onReceive(locationViewModel.$didExitRegion) { value in
            addItem(eventType: .onExit)
        }.onReceive(locationViewModel.$didEnterRegion) { value in
            addItem(eventType: .onEntry)
        }
    }

    private func addItem(eventType: EventType) {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
            newItem.latitude = locationViewModel.location?.latitude ?? 0
            newItem.longitude = locationViewModel.location?.longitude ?? 0
            newItem.eventType = eventType.rawValue

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
