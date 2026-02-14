import SwiftUI
import CoreGraphics
import Combine

struct AnimationBackgroundView: View {
    @EnvironmentObject private var settings: AppSettings
    @State private var neurons: [Neuron] = []
    @State private var connections: [(Int, Int)] = []
    private let neuronCount = 40
    private let timer = Timer.publish(every: 1.0/60, on: .main, in: .common).autoconnect()

    struct Neuron: Identifiable {
        let id = UUID()
        var position: CGPoint
        var drift: CGVector
        var radius: CGFloat
        var opacity: Double
        var fadeSpeed: Double
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Draw lines between connected neurons
                ForEach(connections.indices, id: \.self) { index in
                    let pair = connections[index]
                    let n1 = neurons[pair.0]
                    let n2 = neurons[pair.1]
                    Path { path in
                        path.move(to: n1.position)
                        path.addLine(to: n2.position)
                    }
                    .stroke(settings.secondaryColor.opacity(min(n1.opacity, n2.opacity) * 0.6), lineWidth: 0.8)
                }

                // Draw neurons
                ForEach(neurons) { neuron in
                    Circle()
                        .fill(settings.secondaryColor)
                        .frame(width: neuron.radius * 2,
                               height: neuron.radius * 2)
                        .position(neuron.position)
                        .opacity(neuron.opacity)
                }
            }
            .onAppear {
                neurons = (0..<neuronCount).map { _ in randomNeuron(in: geo.size) }
                connections = generateAllConnections()
            }
            .onReceive(timer) { _ in
                updateNeurons(size: geo.size)
            }
        }
        .background(settings.mainColor)
        .ignoresSafeArea()
    }

    // Generate all connections for current neurons
    private func generateAllConnections() -> [(Int, Int)] {
        var pairs: [(Int, Int)] = []
        let lineThreshold: CGFloat = 100
        for i in 0..<neurons.count {
            let n1 = neurons[i]
            for j in i+1..<neurons.count {
                let n2 = neurons[j]
                let distance = hypot(n1.position.x - n2.position.x, n1.position.y - n2.position.y)
                if distance < lineThreshold {
                    pairs.append((i,j))
                }
            }
        }
        return pairs
    }

    // Generate connections involving a specific neuron index
    private func generateConnections(for index: Int) -> [(Int, Int)] {
        var pairs: [(Int, Int)] = []
        let lineThreshold: CGFloat = 100
        let n1 = neurons[index]
        for j in 0..<neurons.count {
            if j == index { continue }
            let n2 = neurons[j]
            let distance = hypot(n1.position.x - n2.position.x, n1.position.y - n2.position.y)
            if distance < lineThreshold {
                pairs.append(index < j ? (index, j) : (j, index))
            }
        }
        return pairs
    }

    // MARK: - Helpers

    private func randomNeuron(in size: CGSize) -> Neuron {
        Neuron(
            position: CGPoint(x: CGFloat.random(in: 0...size.width),
                              y: CGFloat.random(in: 0...size.height)),
            drift: CGVector(dx: CGFloat.random(in: -0.08...0.08),
                            dy: CGFloat.random(in: -0.08...0.08)),
            radius: CGFloat.random(in: 1...5),
            opacity: 1.0,
            fadeSpeed: Double.random(in: 0.0015...0.005)
        )
    }

    private func updateNeurons(size: CGSize) {
        for i in neurons.indices {
            var neuron = neurons[i]

            // Move neuron
            neuron.position.x += neuron.drift.dx
            neuron.position.y += neuron.drift.dy

            // Decrease opacity independently
            neuron.opacity -= neuron.fadeSpeed
            var respawned = false
            if neuron.opacity < 0 {
                neuron = randomNeuron(in: size)
                respawned = true
            }

            // Respawn if outside bounds
            if neuron.position.x < 0 || neuron.position.x > size.width ||
                neuron.position.y < 0 || neuron.position.y > size.height {
                neuron = randomNeuron(in: size)
                respawned = true
            }

            neurons[i] = neuron

            if respawned {
                // Remove old connections involving this neuron
                connections.removeAll { $0.0 == i || $0.1 == i }
                // Add new connections involving this neuron
                connections.append(contentsOf: generateConnections(for: i))
            }
        }
    }
}
