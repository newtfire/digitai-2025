import os
import json
from neo4j import GraphDatabase
from framework.utils.configLoader import ConfigLoader

class GraphLoader:
    """
    This class loads your fully structured TEI document graphs into Neo4j,
    directly from your XSLT-generated JSON structure.
    """

    def __init__(self, config: ConfigLoader, corpusName: str):
        self.inputPath = os.path.join(config.get('dataPaths.extractedRoot'), corpusName)
        self.neo4jUri = config.get('neo4j.uri')
        self.neo4jUser = config.get('neo4j.user')
        self.neo4jPassword = config.get('neo4j.password')

        self.driver = GraphDatabase.driver(self.neo4jUri, auth=(self.neo4jUser, self.neo4jPassword))

    def close(self):
        self.driver.close()

    def processAllDocuments(self):
        with self.driver.session() as session:
            for fileName in os.listdir(self.inputPath):
                if not fileName.endswith('.json'):
                    continue

                filePath = os.path.join(self.inputPath, fileName)
                with open(filePath, 'r', encoding='utf-8') as f:
                    data = json.load(f)

                documentId = os.path.splitext(fileName)[0]
                session.execute_write(self.loadDocumentGraph, documentId, data)
                print(f"Inserted graph for document: {documentId}")

    @staticmethod
    def loadDocumentGraph(tx, documentId, data):
        # Create the Document node
        title = data.get("title", "Untitled Document")
        tx.run("""
            MERGE (doc:Document {id: $documentId})
            SET doc.title = $title
        """, documentId=documentId, title=title)

        # Process each PART (front, body, back, etc.)
        for partObj in data.get("CONTAINS-PARTS", []):
            part = partObj.get("PART", "")
            partNodeId = f"{documentId}_{part}"

            tx.run("""
                MERGE (part:Part {id: $partNodeId})
                SET part.name = $part
                MERGE (doc:Document {id: $documentId})
                MERGE (doc)-[:CONTAINS]->(part)
            """, partNodeId=partNodeId, part=part, documentId=documentId)

            # Process chapters inside the part
            for chapterObj in partObj.get("CONTAINS-CHAPTERS", []):
                chapterTitle = chapterObj.get("CHAPTER", "")
                chapterId = chapterObj.get("ID", f"{partNodeId}_chapter")

                tx.run("""
                    MERGE (chap:Chapter {id: $chapterId})
                    SET chap.title = $chapterTitle
                    MERGE (part:Part {id: $partNodeId})
                    MERGE (part)-[:CONTAINS]->(chap)
                """, chapterId=chapterId, chapterTitle=chapterTitle, partNodeId=partNodeId)

                # Process sections
                for sectionObj in chapterObj.get("CONTAINS-SECTIONS", []):
                    sectionTitle = sectionObj.get("SECTION", "")
                    sectionId = sectionObj.get("ID", f"{chapterId}_section")

                    tx.run("""
                        MERGE (sec:Section {id: $sectionId})
                        SET sec.title = $sectionTitle
                        MERGE (chap:Chapter {id: $chapterId})
                        MERGE (chap)-[:CONTAINS]->(sec)
                    """, sectionId=sectionId, sectionTitle=sectionTitle, chapterId=chapterId)

                    # Process paragraphs inside sections
                    for paraObj in sectionObj.get("CONTAINS-PARAS", []):
                        paraText = paraObj.get("PARA", "")
                        paraId = f"{sectionId}_para_{hash(paraText) % 1000000}"

                        tx.run("""
                            MERGE (para:Paragraph {id: $paraId})
                            SET para.text = $paraText
                            MERGE (sec:Section {id: $sectionId})
                            MERGE (sec)-[:CONTAINS]->(para)
                        """, paraId=paraId, paraText=paraText, sectionId=sectionId)

                    # Process possible subsections recursively (if any)
                    for subSectionObj in sectionObj.get("CONTAINS-SUBSECTION", []):
                        subSectionTitle = subSectionObj.get("SECTION", "")
                        subSectionId = subSectionObj.get("ID", f"{sectionId}_subsection")

                        tx.run("""
                            MERGE (sub:SubSection {id: $subSectionId})
                            SET sub.title = $subSectionTitle
                            MERGE (sec:Section {id: $sectionId})
                            MERGE (sec)-[:CONTAINS]->(sub)
                        """, subSectionId=subSectionId, subSectionTitle=subSectionTitle, sectionId=sectionId)