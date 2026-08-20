# Rafael Alexis Recinto
## INF231MWA
## CTADMOBL Advance Mobile Programming
 
A new Flutter project that focuses on advance topics. Covering the Mobile to Web Transactions.
 
## Lab Activity Instance

Lab 1: Keeping Track of State (Without Losing Our Minds)

When building an app, data changes constantly. A user adds an item to a cart, or toggles dark mode. How do we keep the screen updated without breaking everything?

    setState(): Think of this as the quick, local fix. It is built right into Flutter. When data inside a single, specific widget changes, setState() tells just that one piece of the screen to redraw itself.

    Provider: As the app grows, passing data from screen to screen gets incredibly messy. Provider is a package that acts like a global broadcasting station. Instead of manually handing data down a massive chain of widgets, Provider lets any widget tune in and listen for updates. It keeps the code clean and stops us from having to redraw the entire screen when only one small thing changed.

Lab 2: The Restaurant Architecture

If you want clean, maintainable code, you cannot throw everything into one massive file. We split the app into three main jobs, much like how a restaurant operates:

    The Model (product.dart): This is the recipe card. It does not actually cook anything; it just defines exactly what a "Product" is supposed to look like (e.g., it requires a name, a price, and an image).

    The Service (product_service.dart): This is the kitchen staff. It does the heavy lifting of talking to the internet (the API), grabbing the raw ingredients (data), and preparing them exactly how the Model's recipe dictates.

    The Screen (product_screen.dart): This is the waiter. It asks the Service for the food, asks the user to wait a second (usually showing a loading spinner via a FutureBuilder), and then serves the finished dish to the screen.

The Big Takeaway: This setup implements a design pattern called Separation of Concerns. The waiter (Screen) never goes into the kitchen to cook, and the kitchen (Service) never talks to the customers. Because of this isolation, if our API changes, we only have to update the kitchen code. If we want to change the app's colors, we only touch the waiter code.
Lab 3: Working Smarter, Not Harder with APIs

How do we make navigating between screens feel fast and seamless when relying on the internet?

    The Data Bridge: Our cart API is a bit lazy—it only gives us a tiny summary of a product. If a user taps a cart item to see its full details, we cannot just pass that tiny summary to the Detail Screen. Instead, the Cart Screen acts as a bridge. It takes the item's ID, quickly asks the Service to fetch the full details in the background, and then opens the Detail Screen.

    Modular Code: Because we separated our concerns in Lab 2, our user interface code is not cluttered with complex network requests. We can easily call our Service from anywhere in the app to grab fresh data.

    Efficiency via getById: Imagine downloading an entire library just to read one book. That is what happens if you do not use targeted API calls. By adding a specific ID to our API requests (like asking the server specifically for product #5), the server hands us exactly what we need and nothing more. This precision saves bandwidth, reduces lag, and makes the app feel incredibly snappy.