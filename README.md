# Rafael Alexis Recinto
## INF231MWA
## CTADMOBL Advance Mobile Programming
 
A new Flutter project that focuses on advance topics. Covering the Mobile to Web Transactions.
 
## Lab Activity Instance

setState() is Flutter's built-in method for managing state within a single widget, it rebuilds that widget whenever its data changes. Provider is a third-party package used for state management across multiple widgets and screens, avoiding the need to manually pass data down through widget parameters. As an app grows, Provider makes state easier to share and update without rebuilding entire widget trees.

The application is built around three main parts that work together like a restaurant team, each with its own job. The Model, found in product.dart, acts like a recipe card. It does no work itself, it simply describes what a "Product" looks like, including its name, price, and image.

The Service, found in product_service.dart, acts like the kitchen. It fetches raw data from an API, a way for programs to request information from each other, then shapes that data into Product objects following the Model's blueprint.

The Screen, found in product_screen.dart, plays the waiter. It asks the Service for data, waits while it loads using FutureBuilder, a widget that shows a spinner until the data arrives, and then displays it to the user.

The process flows in one direction: the Screen requests data, the Service fetches and shapes it using the Model, and hands the finished list back for the Screen to display. Each part sticks to its own role, keeping the code organized.

This structure follows a design pattern called Separation of Concerns, also known as the Service Layer or Repository Pattern. Instead of the Screen contacting the API directly, it always goes through the Service first, similar to how a waiter never enters the kitchen to cook. This keeps the app easy to maintain: if the API changes, only the Service needs updating, and if the design changes, only the Screen is touched.