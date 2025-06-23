
# DigitAI Master Project Documentation (June 2025)

---

## Phase 1: Master Project Overview

### Project Name
**DigitAI TEI/XML Coding Tutor**

### Project Purpose
- Build an AI-powered tutoring assistant for TEI/XML encoding, targeted at document archival work, following TEI P5 subset standards.
- Assist students, archivists, and digital humanities researchers in encoding historical documents correctly, with live tutoring-like interaction.
- Focus on long-context understanding, correct markup structures, and strict TEI guidelines compliance.

### Primary Models
- **Qwen2-8B**
- **LLaMA 3.2-7B**
- Both models are integrated and used based on performance and evaluation.
- Fully self-hosted with no external cloud dependencies.

### Core RAG Strategy
- **Retrieval-Augmented Generation (RAG)** system.
- RAG Corpus includes:
  - Entire TEI P5 subset guidelines.
  - All schemas, official examples, structural definitions, element descriptions, and controlled vocabularies from TEI P5.
  - No external TEI documents are included at this phase; external documents may be added in future phases.

### Database Architecture
- **Neo4j Community Edition 5.11+** with **APOC (apoc-5.11.0-core)** plugin.
- Full hierarchical tree structure of TEI P5 guidelines stored as graph.
- **Neo4jVector** plugin used for unified vector storage and semantic search.

### Embedding Strategy
- **Embedding Model:** BGE-M3
- TEI P5 content embedded into Neo4jVector using BGE-M3 embeddings.

### System Use Cases
- **Markup Suggestion Mode:** Suggest TEI markup for raw or partially encoded text.
- **Markup Review Mode:** Review existing TEI-encoded documents for correctness.
- **Teaching Mode:** Explain TEI concepts, elements, and schema logic interactively.

### Deployment
- Fully local deployment.
- Presented at DH 2025 Lisbon (workshop, poster, short paper).

---

## Phase 2: Technical Configuration

### Part 1: Core Stack

**Models**
- Qwen2-8B (local)
- LLaMA 3.2-7B (local)
- Quantization planned for deployment.

**Databases**
- Neo4j Community Edition 5.11+
- APOC plugin (apoc-5.11.0-core)
- Neo4jVector
- Full consolidation inside Neo4j for both graph and vector operations.

**Embedding Strategy**
- Embedding Model: BGE-M3
- Embedding Source: Full TEI P5 subset

**Pipeline Components**
- Source: TEI P5 XML subset
- XSLT Transformation to JSONL (element-level)
- Embedding Ingestion: BGE-M3 → Neo4jVector
- Graph Ingestion: TEI hierarchy → Neo4j

---

### Part 2: File Formats & Data Structures

**Source Data Files**
- `p5subset.xml` — Official TEI P5 subset
- `p5subset-to-json.xsl` — XSLT transformation script
- `test` — Sample transformed JSONL output

**JSONL Schema**
- `element_name`
- `description`
- `attributes` (array of name-description pairs)
- `examples`
- `hierarchy_path`
- `related_elements`

**Embedding Input Format**
- Flattened combination of fields into text blocks for embedding ingestion into BGE-M3.

**Graph Input Format**
- Full TEI element hierarchy stored in Neo4j graph nodes and relationships.

---

### Part 3: Chunking & Retrieval Assembly Strategy

**Chunking Approach**
- One TEI element (one JSON object) = one embedding unit.
- No sub-chunking currently applied; subject to future refinement.

**Embedding Composition**
- Fields combined into a single text block for embedding.
- `hierarchy_path` and `related_elements` included as space permits.

**Retrieval Assembly Flow**
- Vector search (BGE-M3)
- Neo4jVector top-N retrieval
- Optional graph traversal for structural context
- Final assembled context window for model prompt.

**Note:** Chunking and retrieval strategy may evolve with project development.

---

### Part 4: Fine-tuning Strategy

**Current Approach**
- RAG-first architecture.
- Fine-tuning optional; deferred until after prototype RAG evaluation.
- Possible lightweight instruction-tuning for:
  - Improved explanations
  - Better step-by-step tutoring dialogue

**Training Data Format (if applied)**
- Instruction-tuning JSONL format.
- Tasks: markup generation, correction, and explanation.

---

### Part 5: Deployment Infrastructure

**Hardware Platforms**

| Internal Name | Type | Role |
|----------------|----------|------|
| **Ursa Major** | Mac Studio M4 Max (128GB RAM, 4TB SSD) | Primary server for DigitAI |
| **Ursa Minor** | Mac Studio M4 Max (36GB RAM, 500GB SSD) | Secondary development support |

**Software Stack (Shared)**
- Neo4j Community Edition 5.11+
- APOC Plugin (apoc-5.11.0-core)
- Neo4jVector
- BGE-M3 (embedding model)
- Qwen2-8B
- LLaMA 3.2-7B
- XSLT Processor (XML→JSONL)
- Fully offline, self-hosted.

**Runtime Environment**
- macOS (Apple Silicon native)
- Quantized GGUF models or equivalent
- Serving frameworks: Ollama, LM Studio, vLLM, or custom
- Embedding runtime: HF pipelines or Apple Silicon-compatible frameworks
- Backend orchestration layer (planned)
- UI: CLI or web interface (planned)

---

### Part 6: Current Scripts, Tools, and Codebase Status

**Current Assets**
- `p5subset.xml` — TEI P5 subset XML
- `p5subset-to-json.xsl` — XSLT transform
- `test` — JSONL output example
- BGE-M3 embedding model (local copy)
- Neo4j setup with APOC and Neo4jVector
- Qwen2-8B model weights (local)
- LLaMA 3.2-7B model weights (local)

**Pipeline Status**
- XSLT pipeline: ✅ Complete
- Embedding ingestion: ⚠ In Development
- Graph ingestion: ⚠ In Development
- RAG orchestration layer: ⚠ Planned
- Model serving: ⚠ Evaluation underway
- Fine-tuning data prep: ⚠ Future phase
- Tutor interface: ⚠ Planned

---

# ✅ This document is now your Canonical Master Project Reference for DigitAI (June 2025)
