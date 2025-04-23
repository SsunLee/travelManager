import ProjectDescription

let project = Project(
  name: "travelManager",
  targets: [
    .target(
        name: "travelManagerApp",
        destinations: [.mac,.iPhone],
        product: .app,
        bundleId: "com.sunbae.travelManager")
      ]
  


)
