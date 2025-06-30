<?xml version="1.0" encoding="UTF-8"?>
        // =================================================================
        // 1. SETUP: Create Constraints for Performance and Data Integrity
        // =================================================================
        CREATE CONSTRAINT IF NOT EXISTS FOR (d:Document) REQUIRE d.title IS UNIQUE;
        CREATE CONSTRAINT IF NOT EXISTS FOR (s:Section) REQUIRE s.id IS UNIQUE;
        CREATE CONSTRAINT IF NOT EXISTS FOR (spec:Specification) REQUIRE spec.name IS UNIQUE;
        
        
        // =================================================================
        // 2. LOAD AND PROCESS: Load the JSON and iterate through it
        // =================================================================
      
      CALL apoc.load.json("file:///sandboxTest.json") YIELD value
      
      // Create the single root Document node
      MERGE (doc:Document {title: value.DOC_TITLE})MERGE (doc:Document {name: document_data.DOC_TITLE})
          // Process each Part (front, body)
      FOREACH (part_data in value.CONTAINS_PARTS |
        MERGE (part:Part {name: part_data.PART})
            
        MERGE (doc)-[:HAS_PART]-&gt;(part)
     // FOREACH (part_data IN value.CONTAINS_PARTS |
     //   MERGE (part:Part {name: part_data.PART})
     //   MERGE (doc)-[:HAS_PART]-&gt;(part)
        
        