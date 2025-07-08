 CALL
            apoc.load.json("file:///digitai-RAG-data.json") YIELD value AS json_data
             MERGE (doc:Document { title: json_data.DOCUMENT_TITLE, preparedBy: json_data.PREPARED_BY, teiSourceVersion: json_data.TEI_SOURCE_VERSION_NUMBER, teiSourceOutputDate: json_data.TEI_SOURCE_OUTPUT_DATE, thisJsonDatetime: json_data.THIS_JSON_DATETIME
             FOREACH (PART_data IN
                json_data.CONTAINS_PARTS | MERGE (part:Part {name:
                data.PART) MERGE (doc)-[:CONTAINS_PART]->(part)
             FOREACH
                (CHAPTER_data IN json_data.CONTAINS_CHAPTERS | MERGE (chapter:Chapter {id: chapter_data.ID}) ON
            CREATE SET chapter.chapter = chapter_data.CHAPTER
            
        