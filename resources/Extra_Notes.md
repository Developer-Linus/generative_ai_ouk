# 📝 Background Notes for Learning Jac (with Analogies)

---

## 1. Jac at a Glance

* Jac is a **programming language for graphs**.
* Graphs = **things (nodes)** + **connections (edges)**.
* You tell Jac what things exist, how they connect, and what actions to take.

👉 Analogy: Imagine a **city map**:

* Houses, shops, schools = **nodes**.
* Roads connecting them = **edges**.
* Walking from one place to another = **walker**.

---

## 2. The Three Core Pieces

### 🟢 **Nodes** = "Objects/Things"

* A **node** is an entity that holds information.
* Like a **card in your wallet**: your ID card has your name, age, etc.

Example:

* In real life: *You* are a node with attributes (name, age).
* In Jac:

  ```jac
  node Person {
    has name: str;
    has age: int;
  }
  ```

---

### 🔗 **Edges** = "Relationships/Connections"

* An **edge** is how nodes are connected.
* Like a **friendship**: you and your friend are two nodes, and your friendship is the edge.
* Edges don’t carry much info, but they show the path.

Example:

* Real life: *You* know *Alice*.
* In Jac:

  ```jac
  edge Friend {}
  ```

---

### 🚶 **Walkers** = "People Moving Around"

* A **walker** is like a **messenger** that moves through nodes and does tasks.
* It can read, write, or change data while moving.

Analogy:

* Think of a **postman**: he walks from house to house (nodes), following roads (edges), delivering or picking messages (actions).

Example:

* Real life: You tell the postman “bring me all letters from my friends.”
* In Jac:

  ```jac
  walker collect_messages {}
  ```

---

## 3. The Environment of Jac

* **Root** = the starting point (like the **city center**).
* **Here** = your current position (like the **building you’re inside**).
* **Report** = a message you send back (like the **postman returning to you** with info).

Analogy:

* You start at the city center (root).
* You go to a shop (here).
* You buy milk and return home with it (report).

---

## 4. Jac’s File System

Jac organizes code in **3 layers**, like how we organize our lives:

1. **Definitions (What exists?)**

   * Define nodes (people, shops, roads).
   * Define edges (friendships, trade routes).

2. **Implementations (What happens?)**

   * Define actions (how people shop, how they greet friends).

3. **Tests (Does it work?)**

   * Try out scenarios to confirm the rules work.

Analogy:

* Definitions = a **map legend** (what’s on the map).
* Implementations = **rules of the city** (traffic moves left, shop opens at 9).
* Tests = **walking through the city** to see if the rules work (shop is actually open at 9).

---

## 5. How Jac Runs

When you code in Jac, you use commands:

* **`jac run`** → like **starting the city simulation**.
* **`jac test`** → like **sending inspectors** to check if shops/houses follow the rules.
* **`jac serve`** → like **opening the city gates**, so visitors (API users) can interact with your city.

---

## 6. Why Graphs?

Jac is built for **graph-shaped problems**.

Analogy:

* A **family tree** → parents connected to children.
* A **transport network** → buses connect cities.
* A **disease spread model** → one person infects another.

Graphs let you **trace paths and relationships easily**:

* “Who are my cousins?” → go through parent edges.
* “How do I reach Nairobi from Kisumu?” → follow road edges.
* “Who will be infected next?” → traverse infection edges.

---

## 7. How Jac Differs From Normal Languages

* In **Python/Java**, you build structures in memory and store data in a database.
* In **Jac**, the **graph itself is the database and the program at once**.

Analogy:

* Normal programming = **building a house in a field, then storing its address in a separate registry**.
* Jac = **building a house directly on the map, already connected to everything**.

---

## 8. Basic Jac Keywords

* `node` → defines a **thing**.
* `edge` → defines a **connection**.
* `walker` → defines a **messenger** that moves around.
* `impl` → defines the **action logic**.
* `root` → starting place.
* `here` → current place.
* `report` → send info back.
* `spawn` → create something new.

---

## 9. Real-World Mini Example

Imagine you want to model a **school**:

* Nodes:

  * `Student`, `Teacher`, `Classroom`.

* Edges:

  * `StudiesIn` (connects Student → Classroom).
  * `TeachesIn` (connects Teacher → Classroom).

* Walkers:

  * `enroll_student` (puts a student into a classroom).
  * `assign_teacher` (connects a teacher to a classroom).
  * `list_classmates` (walks through the classroom to find other students).

Analogy:

* A school is just a **graph of relationships**.
* Jac lets you create and explore it directly.

---

## 10. Mindset Before Coding

* Always think in **nodes and relationships**.
* Imagine you are drawing a **map of people, things, and how they connect**.
* Then, walkers are just **people walking on the map, doing stuff**.

---

# Jac Background Notes (Theory Only)

---

## **1. Graphs = Maps of the World**

Jac thinks in **graphs**:

* **Nodes** = things (like cities, people, animals).
* **Edges** = connections (like roads, friendships, rivers).

**Analogy:** Imagine Nairobi’s matatu routes:

* Stage = Node
* Road between stages = Edge
* Matatu moving = Walker

If you can visualize matatu routes, you can visualize Jac graphs.

---

## **2. Walkers = Messengers**

Walkers are little workers that **move through the graph**.

* They can *look around* at the node they’re standing on.
* They can *carry information* back.
* They can *do tasks* like creating or connecting nodes.

**Analogy:**
Think of a **health inspector** visiting houses:

* Each house = Node
* Path between houses = Edge
* Inspector walking = Walker
* Inspector’s notebook = Report

---

## **3. Attributes = Details of Things**

Nodes and edges aren’t just nameless. They have **properties**.

**Analogy:**
A student card has:

* Name
* Age
* ID number

In Jac, a `Person` node could carry those details as attributes.

---

## **4. Spawning = Giving Birth**

Graphs can grow. New nodes and edges can be created at runtime.

**Analogy:**

* A school admits a new student → new `Person` node.
* The school links them with “EnrolledIn” edge.

So Jac lets you **expand your map dynamically**.

---

## **5. Traversals = Exploring Paths**

Walkers can follow edges to reach other nodes.

**Analogy:**

* Starting at home, you can walk: Home → Shop → Market.
* In Jac: Person → LivesIn → City → HasRoad → AnotherCity.

So Jac walkers can **navigate networks of relationships**.

---

## **6. Implementations = Behaviors**

Nodes can carry logic too, not just data.

**Analogy:**
Think of a **vending machine**:

* Machine = Node
* Button pressed = Trigger
* Soda comes out = Behavior

In Jac: a `BankAccount` node could implement **deposit()** and **withdraw()** rules.

---

## **7. Reports = The Story Told Back**

After walking the graph, the walker can send results.

**Analogy:**
Like a journalist covering a story:

* Visits places (nodes).
* Talks to people (attributes).
* Writes an article (report).

In Jac, `report` collects data back to the user.

---

## **8. Anchors = Bookmarks**

Walkers may want to **remember spots** in the graph.

**Analogy:**
Like dropping a pin on Google Maps.

* “This is where my friend lives, I’ll come back later.”

Jac lets you store references to nodes so you can revisit.

---

## **9. Jac Philosophy**

Jac is like **Python + Graph Database + OOP + AI orchestration**.

* Instead of files and functions, you think in **entities and connections**.
* Instead of “if-else” only, you also *walk around a world of data*.

**Analogy:**
If Python is a **notebook** where you write down recipes,
Jac is a **city map** where you actually move around and cook with people in their homes.

---

## **10. Where This Gets Powerful**

Jac is designed for **AI + real-world problems**:

* You can model **people, hospitals, crops, schools** as graphs.
* You can design **walkers** that act like **AI agents** moving in these graphs.
* You can then **connect Jac to LLMs (via Byllm)** so walkers get “brains” powered by AI.

**Analogy:**
Imagine a farmer chatbot:

* Graph = farm with crops, soil, weather data.
* Walker = farm inspector.
* AI = brain that gives advice based on what the walker sees.

---
Perfect 🌱 Let’s build a **detailed farm example** in pure **theory** (no Jac code yet) so you can “see” how Jac concepts map to a **real Kenyan farm**.

---

# 🚜 Example: A Kenyan Farm as a Graph

---

## **1. Nodes (Things in the Farm)**

Imagine you have a **small farm in Kericho**. What are the important things?

* **Farmer** → the person who owns/works the farm.
* **Crop** → tea, maize, sukuma wiki, beans.
* **Animal** → cow, goat, chicken.
* **Soil** → the land/plot.
* **Market** → where produce is sold.
* **WeatherStation** → source of rainfall/temperature info.

👉 In Jac, each of these is a **node**.

---

## **2. Edges (Connections Between Things)**

Now, how are they linked?

* Farmer **owns** Crop, Animal, and Soil.
* Crop **grows_in** Soil.
* Animal **feeds_on** Crop.
* Farmer **sells_to** Market.
* Soil **affected_by** WeatherStation.

👉 Each connection is an **edge** in Jac.

---

## **3. Attributes (Details on Each Thing)**

Each node/edge has **properties** (data about it).

* **Farmer**: name = “Linus”, age = 28, experience = 3 years.
* **Crop**: type = maize, stage = flowering, health = good.
* **Animal**: type = cow, age = 2 years, milk_production = 10 liters/day.
* **Soil**: fertility = medium, moisture = low, pH = 6.2.
* **Market**: location = Kericho town, demand = high for maize.
* **WeatherStation**: rainfall = 20mm, temperature = 22°C.

👉 These are **attributes** declared on nodes.

---

## **4. Walkers (Farm Inspectors or Agents)**

Walkers are like **workers moving across the farm** doing tasks.

Examples:

* `inspect_crops` → visits each crop and reports health.
* `check_soil` → measures fertility and moisture.
* `collect_milk` → goes to each cow, adds up milk.
* `plan_sales` → visits market node and suggests what to sell.

👉 Walkers bring back useful insights, just like **agricultural extension officers** visiting farms.

---

## **5. Spawning (Growing the Farm)**

The farm grows over time.

* New season → spawn new Crop (e.g., sukuma wiki).
* Farmer buys goat → spawn new Animal.
* Expands to another plot → spawn new Soil node.

👉 Jac can dynamically add these nodes/edges at runtime.

---

## **6. Traversals (Moving Around the Farm)**

How would a walker move?

* Start at Farmer → follow **owns** → reach all Crops.
* From Crop → follow **grows_in** → reach Soil → then **affected_by** → WeatherStation.
* From Farmer → follow **sells_to** → reach Market.

👉 Traversals let you see **how everything is connected** (just like walking through shamba paths).

---

## **7. Implementations (Behaviors of Nodes)**

Nodes can have **built-in logic**, like rules.

Examples:

* **Crop** node → `needs_water()` = true if soil moisture < 30%.
* **Animal** node → `milk_today()` returns liters of milk.
* **Market** node → `expected_price(crop_type)` returns price forecast.

👉 Think of it as **farm rules programmed into the system**.

---

## **8. Reporting (Farm Reports)**

Walkers bring back **summaries**:

* “3 maize crops are healthy, 1 is diseased.”
* “Soil moisture is too low, irrigation needed.”
* “Total milk today = 25 liters.”
* “Best price for maize in Kericho market = KSh 70/kg.”

👉 Just like **reports farmers receive from co-ops or extension officers**.

---

## **9. Anchors (Bookmarks on the Farm)**

Sometimes you need to mark a node for later.

* Anchor the “sick maize crop” so the vet can revisit.
* Anchor the “cow producing the most milk” for special care.

👉 Anchors = **pins on the farm map**.

---

## **10. Putting It Together**

The farm graph in Jac can **answer big questions**:

* Which crops need irrigation right now?
* What’s the total expected harvest next month?
* Which animals are profitable?
* What’s the best market to sell produce?

👉 This is how **Jac + AI (via Byllm)** can help **Kenyan farmers** with data-driven decisions.

---

⚡ **Key Takeaway**:
Jac lets you **model the farm as a living map**:

* Nodes = Farm elements (farmer, crops, soil, animals, market).
* Edges = Relationships (owns, grows_in, sells_to).
* Walkers = Inspectors/agents that move around and report.

---
