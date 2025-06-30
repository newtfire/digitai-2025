<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:my="https://my.namespace/for/function-definitions" exclude-result-prefixes="xs math"
    version="3.0">

    <xsl:variable name="sourceDoc" as="document-node()" select="doc('sandboxTest.xml')"/>
    
   <!-- FUNCTIONS AND TEMPLATES FOR GENERATING JSON DATA FROM SOURCE XML -->

    <xsl:function name="my:sectionMapper" as="map(*)*">
        <xsl:param name="section" as="element()+"/>
        <xsl:for-each select="$section">
            <xsl:variable name="section" as="element()?" select="current()"/>
            <xsl:map>
                <xsl:map-entry key="$section/@type ! upper-case(.)">
                    <xsl:value-of select="$section/head ! normalize-space()"/>
                </xsl:map-entry>
                <xsl:if test="$section[@xml:id]">
                    <xsl:map-entry key="'ID'">
                        <xsl:value-of select="$section/@xml:id ! normalize-space()"/>
                    </xsl:map-entry>
                </xsl:if>
                <!-- Is this a div with nested divs? If so, continue processing those subsections. -->
                <xsl:if test="$section/div">
                    <xsl:map-entry key="'CONTAINS_SECTIONS'">
                        <xsl:sequence select="
                                array {
                                    for $s in $section/div
                                    return
                                        my:sectionMapper($s)
                                }"/>
                    </xsl:map-entry>
                </xsl:if>
                <xsl:map-entry key="'CONTAINS_PARAS'">
                    <xsl:sequence select="
                            array {
                                for $p in $section/p
                                return
                                    my:paraMapper($p)
                            }"/>
                </xsl:map-entry>

            </xsl:map>
        </xsl:for-each>
    </xsl:function>

    <xsl:function name="my:paraMapper" as="map(*)*">
        <xsl:param name="para" as="element()"/>
        <xsl:map>
            <xsl:map-entry key="'PARASTRING'">
                <xsl:value-of select="$para ! normalize-space()"/>
            </xsl:map-entry>
            <xsl:if test="$para/*">
                <xsl:choose>
                    <xsl:when test="$para/*[self::specGrp]">
                        <xsl:map-entry key="'CONTAINS_SPECGRP'">
                            <xsl:sequence select="array {my:specGrpMapper($para/specGrp)}"/>
                        </xsl:map-entry>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:map-entry key="'CONTAINS_SPECLIST'">
                            <xsl:variable name="specRefs" as="map(*)*">
                                <xsl:for-each select="$para//specDesc">
                                    <xsl:map>
                                        <xsl:map-entry key="'LINK_TO_SPEC'">
                                            <xsl:value-of
                                                select="current()/@key ! normalize-space()"/>
                                        </xsl:map-entry>

                                    </xsl:map>
                                </xsl:for-each>
                            </xsl:variable>
                            <xsl:sequence select="array {$specRefs}"/>
                        </xsl:map-entry>

                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
        </xsl:map>
    </xsl:function>

    <xsl:function name="my:specGrpMapper" as="map(*)*">
        <xsl:param name="specGrp" as="element()"/>
        <xsl:variable name="specs" as="element()+" select="$specGrp/spec"/>
        <xsl:for-each select="$specs">
            <xsl:map>
                <xsl:map-entry key="'SPEC'">
                    <xsl:value-of select="current()/@ident ! normalize-space()"/>
                </xsl:map-entry>
                <xsl:if test="current()/p">
                    <xsl:map-entry key="'CONTAINS-PARAS'">
                        <xsl:sequence select="
                                for $p in current()/p
                                return
                                    my:paraMapper($p)"/>
                    </xsl:map-entry>
                </xsl:if>
                <xsl:map-entry key="'CONTENT'">
                    <xsl:sequence select="current()/contentModel ! name()"/>
                </xsl:map-entry>
            </xsl:map>

        </xsl:for-each>

    </xsl:function>

    <xsl:template match="/">
        <xsl:result-document href="sandboxTest.json" method="json" indent="yes">
            <xsl:map>
                <xsl:map-entry key="'DOC_TITLE'">SOURCE XML AS BASIS FOR A KNOWLEDGE GRAPH</xsl:map-entry>
                <xsl:variable name="parts" as="map(*)*">
                    <xsl:for-each select="$sourceDoc/*/*">
                        <xsl:map>
                            <xsl:map-entry key="'PART'">
                                <xsl:sequence select="current() ! name() ! normalize-space()"/>
                            </xsl:map-entry>
                            <xsl:map-entry key="'CONTAINS_CHAPTERS'">
                                <xsl:sequence select="array {my:sectionMapper(current()/div)}"/>
                            </xsl:map-entry>
                        </xsl:map>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:map-entry key="'CONTAINS_PARTS'">
                    <xsl:sequence select="array {$parts}"/>
                </xsl:map-entry>

            </xsl:map>
        </xsl:result-document>
        <xsl:apply-templates select="/" mode="cypher"/>
    </xsl:template>
    
<!-- CYPHER MAP, FUNCTIONS AND TEMPLATES FOR IMPORTING THE JSON AND BUILDING THE GRAPH -->
    
    <!-- MAP FOR THE GRAPH MODEL -->
    
    <xsl:variable name="my:graph-model" as="map(xs:string, map(*))">
        <xsl:map>
            <xsl:map-entry key="'document'">
                <xsl:map>
                    <xsl:map-entry key="'label'">Document</xsl:map-entry>
                    <xsl:map-entry key="'cypherVar'">doc</xsl:map-entry>
                    <xsl:map-entry key="'primaryKey'">name</xsl:map-entry>
                    <xsl:map-entry key="'jsonKeyForPK'">DOC_TITLE</xsl:map-entry>
                    <xsl:map-entry key="'parent'" select="'value'"/>
                    <!-- (the value of the JSON document on import) -->
                    <xsl:map-entry key="'relationship'" select="'HAS_PART'"/>
                </xsl:map>
            </xsl:map-entry>
            <xsl:map-entry key="'part'">
                <xsl:map>
                    <xsl:map-entry key="'label'">Part</xsl:map-entry>
                    <xsl:map-entry key="'cypherVar'">part</xsl:map-entry>
                    <xsl:map-entry key="'primaryKey'">name</xsl:map-entry>
                    <xsl:map-entry key="'jsonKeyForPK'">PART</xsl:map-entry>
                    <xsl:map-entry key="'parent'" select="'document'"/>
                    <xsl:map-entry key="'relationship'" select="'HAS_PART'"/>
                    
                </xsl:map>
            </xsl:map-entry>
            <xsl:map-entry key="'chapter'">
                <xsl:map>
                    <xsl:map-entry key="'label'" select="'Section'"/>
                    <xsl:map-entry key="'cypherVar'" select="'chapter'"/>
                    <xsl:map-entry key="'primaryKey'" select="'id'"/>
                    <xsl:map-entry key="'jsonKeyForPK'" select="'ID'"/>
                    <xsl:map-entry key="'properties'">
                        <xsl:map>
                            <xsl:map-entry key="'title'">CHAPTER</xsl:map-entry>
                            <xsl:map-entry key="'type'">xs:string</xsl:map-entry>
                        </xsl:map>
                    </xsl:map-entry>
                    <xsl:map-entry key="'parent'" select="'part'"/>
                    <xsl:map-entry key="'relationship'" select="'HAS_SECTION'"/>
                </xsl:map>
            </xsl:map-entry>
            
            <xsl:map-entry key="'section'">
                <xsl:map>
                    <xsl:map-entry key="'label'" select="'Section'"/>
                    <xsl:map-entry key="'cypherVar'" select="'section'"/>
                    <xsl:map-entry key="'primaryKey'" select="'id'"/>
                    <xsl:map-entry key="'jsonKeyForPK'" select="'ID'"/>
                    <xsl:map-entry key="'properties'" select="map{'title': 'SECTION', 'type': 'xs:string'}"/>
                    <xsl:map-entry key="'parent'" select="'chapter'"/>
                    <xsl:map-entry key="'relationship'" select="'HAS_SECTION'"/>
                </xsl:map>
            </xsl:map-entry>
        </xsl:map>
    </xsl:variable>
    
    <!-- FUNCTION TO MERGE NODES -->
    <xsl:function name="my:generate-node-merge" as="xs:string">
        <xsl:param name="map-entity-type" as="xs:string"/> 
        <xsl:param name="json-variable" as="xs:string"/> 
        <xsl:variable name="model" select="$my:graph-model($map-entity-type)"/>
        <xsl:sequence select="'MERGE ('||$model('cypherVar')||':'||$model('label')||
            ' {'||$model('primaryKey')||': '||$json-variable||'.'||$model('jsonKeyForPK')|| '})'"/>
    </xsl:function>
    
    <!-- FUNCTION TO ESTABLISH EDGES (RELATIONSHIP CONNECTIONS)-->
    <xsl:function name="my:generate-relationship-merge" as="xs:string">
        <xsl:param name="map-entity-type" as="xs:string"/>
        <xsl:variable name="model" select="$my:graph-model($map-entity-type)"/>
        <xsl:variable name="parent-model" select="$my:graph-model($model('parent'))"/>
        
        <xsl:sequence select="'MERGE ('||$parent-model('cypherVar')||')-[:'||$model('relationship')||']->('||$model('cypherVar')||')'"/>
    </xsl:function>
    
    

    
<xsl:template match="/" mode="cypher">
    <xsl:result-document href="sandbox-cypher-import.cypher">
        <xsl:text>
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
      MERGE (doc:Document {title: value.DOC_TITLE})</xsl:text>
      <xsl:value-of select="my:generate-node-merge('document', 'document_data')"/>
   
      <xsl:text>
          // Process each Part (front, body)
      FOREACH (part_data in value.CONTAINS_PARTS |
        </xsl:text>
      
      <xsl:value-of select="my:generate-node-merge('part', 'part_data')"/>
        <xsl:text>
            
        </xsl:text>
        <xsl:value-of select="my:generate-relationship-merge('part')"/>
       
      
      <xsl:text>
     // FOREACH (part_data IN value.CONTAINS_PARTS |
     //   MERGE (part:Part {name: part_data.PART})
     //   MERGE (doc)-[:HAS_PART]->(part)
        
        </xsl:text>  
        
        
        
        
    </xsl:result-document>
</xsl:template>


</xsl:stylesheet>
