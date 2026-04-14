// swift-tools-version: 6.2

import PackageDescription

let package = Package(
  name: "cossistant-admin-swift",
  platforms: [
    .iOS(.v17),
    .macOS(.v14),
  ],
  products: [
    .library(
      name: "CossistantAdmin",
      targets: ["CossistantAdmin"]
    ),
  ],
  targets: [
    .target(
      name: "CossistantAdmin"
    ),
  ]
)
