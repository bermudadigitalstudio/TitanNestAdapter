import PackageDescription

let package = Package(
  name: "TitanNestAdapter",
  dependencies: [
    .Package(url: "https://github.com/bermudadigitalstudio/titan-core.git", majorVersion: 0),
    .Package(url: "https://github.com/nestproject/Nest.git", majorVersion: 0),
    .Package(url: "https://github.com/nestproject/Inquiline.git", majorVersion: 0)
  ]
)
