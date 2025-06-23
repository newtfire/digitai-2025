# DigitAI Master Project Documentation

---

## Master Project Overview

### Project Purpose

* Build an AI-powered tutoring assistant for TEI/XML encoding, targeted at document archival work, following TEI P5 standards.
* Assist students, archivists, and digital humanities researchers in encoding historical documents correctly, with live tutoring-like interaction.
* Focus on long-context understanding, correct markup structures, and strict TEI guidelines compliance.

### Primary Models

* **Qwen2-8B**
* ~~LLaMA 3.2-7B~~ ==*(No longer in use: multilingual capabilities of LLaMA do not adequately support all languages present in the full P5 build.)*==
* Fully self-hosted with no external cloud dependencies.

### Current Scripts, Tools, and Codebase Status

**Current Assets**

* `p5.xml` — TEI P5 build XML
* `p5-to-json.xsl` — XSLT transform
* `digitai-p5.json` — JSON output from XSLT
* BGE-M3 embedding model (local copy)
* Neo4j setup with APOC and Neo4jVector
* Qwen2-8B model weights (local)
* ~~LLaMA 3.2-7B model weights (local)~~ *(No longer in use)*

**Pipeline Status**

* XSLT pipeline: ⚠ In Development
* Embedding ingestion: ⚠ In Development
* Graph ingestion: ⚠ In Development
* RAG orchestration layer: ⚠ Planned
* Model serving: ⚠ Evaluation underway
* Fine-tuning data prep: ⚠ Future phase
* Tutor interface: ⚠ Planned


### Core RAG Strategy

* **Retrieval-Augmented Generation (RAG)** system.
* RAG Corpusn will include:
  * Entire TEI P5 build.
  * All schemas, official examples, structural definitions, element descriptions, and controlled vocabularies from TEI P5.

  ==No external TEI documents are included at this phase; external documents may be added in future phases.==

### Database Architecture

* **Neo4j Community Edition 5.11+** with **APOC (apoc-5.11.0-core)** plugin.
* Full hierarchical tree structure of TEI P5 build stored as graph.
* **Neo4jVector** plugin used for unified vector storage and semantic search.

### Embedding Strategy

* **Embedding Model:** BGE-M3
* TEI P5 content embedded into Neo4jVector using BGE-M3 embeddings.
* **Why BGE-M3 is required:**

  * Neo4jVector alone provides basic vector storage but does not perform semantic embedding.
  * TEI element descriptions contain dense technical language, complex definitions, and cross-references that require true sentence-level semantic understanding to match user queries.
  * BGE-M3 allows natural language queries (e.g., "How do I encode speech overlaps?") to map effectively onto highly technical TEI element definitions.
  * Without BGE-M3 embeddings, purely structural graph traversal or lexical matching would not provide high-precision retrieval of contextually relevant TEI elements.

### System Use Cases

* **Markup Suggestion:** Suggest TEI markup for raw or partially encoded text.
* **Markup Review:** Review existing TEI-encoded documents for correctness.
* **Teaching:** Explain TEI concepts, elements, and schema logic interactively.

### Deployment

* Fully local deployment. 
* Distilled version is planned when we get the model refined enough for a public release

---

## Technical Configuration

### Core Stack

**Models**

* Qwen2-8B (local)
* ~~LLaMA 3.2-7B~~ *(No longer in use)*
* Quantization/Distillation planned for deployment.

**Databases**

* Neo4j Community Edition 5.11+
* APOC plugin (apoc-5.11.0-core)
* Neo4jVector
* Full consolidation inside Neo4j for both graph and vector operations.

**Embedding Strategy**

* Embedding Model: BGE-M3
* Embedding Source: Full TEI P5 build

**Pipeline Components**

* Source: TEI P5 Build (Full P5)
* XSLT Transformation to JSON (element-level) *(In Development)*
* Parallel Ingestion into Neo4j:

  * Embedding Pipeline: JSON → Flatten → BGE-M3 → Neo4jVector
  * Graph Pipeline: JSON → Nodes & Relationships → Neo4j Graph

---

### File Formats & Data Structures

**Source Data Files**

* `p5.xml` — Official TEI P5 Build (full build)
* `p5-to-json.xsl` — XSLT transformation script
* `digitai-p5.json` — Full output of P5 in hierarchial json format

**Embedding Input Format**

* Flattened combination of fields into text blocks for embedding ingestion into BGE-M3.
* Each JSON object represents one TEI element.

**Graph Input Format**

* Full TEI element hierarchy stored in Neo4j graph nodes and relationships.

---

### Retrieval Assembly Flow (Canonical RAG Pipeline)

**Step 1: Data Preparation**

* The official TEI P5 Build (`p5.xml`) is transformed via custom XSLT (`p5-to-json.xsl`) into element-level JSON objects.
* Each JSON object contains TEI element data, including hierarchy relationships and related elements.
* This JSON dataset feeds two parallel ingestion pipelines:

**Step 2a: Vector Ingestion Pipeline**

* Each JSON object is flattened into a text block.
* Embedded using BGE-M3.
* Embedding vectors are stored in Neo4jVector.

**Step 2b: Graph Ingestion Pipeline**

* Each JSON object also populates Neo4j as a graph node.
* Relationships between nodes reflect TEI hierarchy and related element links.

**Step 3: Retrieval Query Execution**

* User submits a query (natural language or markup-specific question).
* Query is embedded using BGE-M3.
* Neo4jVector performs vector similarity search against stored element embeddings.
* Top-N most semantically relevant TEI elements are retrieved.

**Step 4: Graph Expansion (Structural Context Retrieval)**

* For each Top-N retrieved element:

  * Its immediate **parent** element is retrieved.
  * Its immediate **child** elements are optionally retrieved.
  * Direct **related\_elements** may also be retrieved depending on retrieval depth configuration.
  * This structural expansion provides localized schema grounding to support accurate model reasoning.

**Step 5: Deduplication & Context Assembly**

* All retrieved chunks (from vector search and graph expansion) are deduplicated.
* The selected content is assembled into a unified retrieval output.
* Output format: consolidated JSON document representing the retrieved knowledge window.

**Step 6: Model Prompting**

* The assembled retrieval output is injected into the LLM (Qwen2-8B) as system context.
* The LLM uses this grounded context to generate markup suggestions, explanations, or corrections.

**Note:** The final context window size is under evaluation; the architecture allows flexible adjustment based on future model context length capacities.

---

### Part 4: Fine-tuning Strategy (Held off until RAG is complete)

**PlannedApproach**

* RAG-first architecture.
* Fine-tuning optional; deferred until after prototype RAG evaluation.
* Possible lightweight instruction-tuning for:

  * Improved explanations
  * Better step-by-step tutoring dialogue

**Training Data Format**

* Instruction-tuning JSON format.
* Tasks: markup generation, correction, and explanation.

---

# Deployment Infrastructure 

**Hardware Platforms**

| Internal Name  | Type                                    | Role                          |
| -------------- | --------------------------------------- | ----------------------------- |
| **Ursa Major** | Mac Studio M4 Max (128GB RAM, 4TB SSD)  | Primary server for DigitAI    |
| **Ursa Minor** | Mac Studio M4 Max (36GB RAM, 500GB SSD) | Secondary development support |

**Software Stack (Shared)**

* Neo4j Community Edition 5.11+
* APOC Plugin (apoc-5.11.0-core)
* Neo4jVector
* BGE-M3 (embedding model)
* Qwen2-8B
* ~~LLaMA 3.2-7B~~ *(No longer in use)*
* XSLT Processor (XML→JSON)
* Fully offline, self-hosted.

---





