import Foundation

actor SerialExecutor<Key: Hashable, Value> {
    private typealias Stream = AsyncThrowingStream<Value, Error>

    private enum Runner {
        case root
        case runner(Stream.Continuation)
    }

    private var runners: [Key: [Runner]] = [:]

    func execute(for key: Key, generate: () async throws -> Value) async throws -> Value {
        if runners[key]?.isEmpty ?? true {
            runners[key, default: []].append(.root)

            func cleanup(_ result: Result<Value, Error>) {
                let currentRunners = runners[key] ?? []
                runners[key] = nil

                switch result {
                case .success(let value):
                    for case .runner(let cont) in currentRunners {
                        cont.yield(value)
                        cont.finish()
                    }

                case .failure(let error):
                    for case .runner(let cont) in currentRunners {
                        cont.finish(throwing: error)
                    }
                }
            }

            do {
                let value = try await generate()
                cleanup(.success(value))
                return value
            } catch let error {
                cleanup(.failure(error))
                throw error
            }
        } else {
            let awaiter = Stream.makeStream()
            runners[key, default: []].append(.runner(awaiter.continuation))

            for try await value in awaiter.stream {
                return value
            }
            throw CancellationError()
        }
    }
}
