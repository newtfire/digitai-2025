<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:my="https://my.namespace/for/function-definitions" exclude-result-prefixes="xs math"
    version="3.0">

    <xsl:variable name="sourceDoc" as="document-node()" select="doc('sandboxTest.xml')"/>
    <xsl:variable name="newline" as="xs:string" select="'&#10;'"/>
    <xsl:variable name="tab" as="xs:string" select="'&#x9;'"/>
    <xsl:variable name="nltab" as="xs:string" select="$newline||$tab"/>
    
    <!-- MAP FOR THE GRAPH MODEL -->
    <!-- 2025-06-30 ebb: graph model is complete for this sandbox example, but functions
    require revision! 
    -->
    <xsl:variable name="my:graph-model" as="map(xs:string, map(*))">
        <xsl:map>
            <xsl:map-entry key="'document'">
                <xsl:map>
                    <xsl:map-entry key="'label'">Document</xsl:map-entry>
                    <xsl:map-entry key="'cypherVar'">doc</xsl:map-entry>
                    <xsl:map-entry key="'primaryKey'">name</xsl:map-entry>
                    <xsl:map-entry key="'jsonKeyForPK'">DOC_TITLE</xsl:map-entry>
                  <!-- The document node doesn't really have a parent, so we're not going to use this
                      <xsl:map-entry key="'parent'" select="'value'"/>-->
                    <!-- (Literally the value of the JSON document on import) -->
                    <xsl:map-entry key="'relationship'" select="'HAS_PART'"/>
                    <xsl:map-entry key="'children'">
                           <xsl:sequence select="array{ 
                               map{
                               'jsonChildrenKey': 'CONTAINS_PARTS',
                               'childEntityType': 'part' 
                               }
                               
                               }"/>
                    </xsl:map-entry>
                </xsl:map>
            </xsl:map-entry>
            <xsl:map-entry key="'part'">
                <xsl:map>
                    <xsl:map-entry key="'label'">Part</xsl:map-entry>
                    <xsl:map-entry key="'cypherVar'">part</xsl:map-entry>
                    <xsl:map-entry key="'primaryKey'">name</xsl:map-entry>
                    <xsl:map-entry key="'jsonKeyForPK'">PART</xsl:map-entry>
                    <xsl:map-entry key="'relationship'" select="'HAS_PART'"/>
                    <xsl:map-entry key="'children'">
                        <xsl:sequence select="array{ 
                            map{
                            'jsonChildrenKey': 'CONTAINS_CHAPTERS',
                            'childEntityType': 'chapter' 
                            } 
                            }"/>
                    </xsl:map-entry>
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
                    <xsl:map-entry key="'relationship'" select="'HAS_SECTION'"/>
                    <xsl:map-entry key="'children'">
                        <xsl:sequence select="array{ 
                            map{
                            'jsonChildrenKey': 'CONTAINS_SECTIONS',
                            'childEntityType': 'section' 
                            },
                            map{
                            'jsonChildrenKey': 'CONTAINS_PARAS',
                            'childEntityType': 'paragraphs'
                            }                            
                            }"/>
                    </xsl:map-entry>
                </xsl:map>
            </xsl:map-entry>
            
            <xsl:map-entry key="'section'">
                <xsl:map>
                    <xsl:map-entry key="'label'" select="'Section'"/>
                    <xsl:map-entry key="'cypherVar'" select="'section'"/>
                    <xsl:map-entry key="'primaryKey'" select="'id'"/>
                    <xsl:map-entry key="'jsonKeyForPK'" select="'ID'"/>
                    <xsl:map-entry key="'properties'" select="map{'title': 'SECTION', 'type': 'xs:string'}"/>
                    <xsl:map-entry key="'relationship'" select="'HAS_SECTION'"/>
                    <xsl:map-entry key="'children'">
                        <xsl:sequence select="array{ 
                            map{
                            'jsonChildrenKey': 'CONTAINS_SECTIONS',
                            'childEntityType': 'section' 
                            },
                            map{
                            'jsonChildrenKey': 'CONTAINS_SECTIONS',
                            'childEntityType': 'nestedsubsection' 
                            },
                            map{
                            'jsonChildrenKey': 'CONTAINS_PARAS',
                            'childEntityType': 'paragraphs'
                            }                            
                            }"/>
                    </xsl:map-entry>
                </xsl:map>
            </xsl:map-entry>
            <xsl:map-entry key="'nestedsubsection'">
                <xsl:map>
                    <xsl:map-entry key="'label'" select="'Nestedsubsection'"/>
                    <xsl:map-entry key="'cypherVar'" select="'nestedsubsection'"/>
                    <xsl:map-entry key="'primaryKey'" select="'id'"/>
                    <xsl:map-entry key="'jsonKeyForPK'" select="'ID'"/>
                    <xsl:map-entry key="'properties'" select="map{'title': 'SECTION', 'type': 'xs:string'}"/>
                    <xsl:map-entry key="'relationship'" select="'HAS_SECTION'"/>
                    <xsl:map-entry key="'children'">
                        <xsl:sequence select="array{ 
                            map{
                            'jsonChildrenKey': 'CONTAINS_SECTIONS',
                            'childEntityType': 'section' 
                            },
                            map{
                            'jsonChildrenKey': 'CONTAINS_PARAS',
                            'childEntityType': 'paragraphs'
                            }                            
                            }"/>
                    </xsl:map-entry>
                </xsl:map>
            </xsl:map-entry>
   
                    <xsl:map-entry key="'paragraph'">
                        <xsl:map>
                             <xsl:map-entry key="'label'" select="'Para'"/>
                             <xsl:map-entry key="'cypherVar'" select="'paragraph'"/>
                            <xsl:map-entry key="'primaryKey'" select="'num'"/>
                            <xsl:map-entry key="'jsonKeyForPK'" select="'NUM'"/>
                            <xsl:map-entry key="'properties'">
                                <xsl:map>
                                    <xsl:map-entry key="'contents'">PARASTRING</xsl:map-entry>
                                </xsl:map>
                            </xsl:map-entry>
                            <xsl:map-entry key="'children'">
                                <xsl:sequence select="array{ 
                                    map{
                                    'jsonChildrenKey': 'CONTAINS_SPECLIST',
                                    'childEntityType': 'speclist'
                                    },
                                    map{ 
                                    'jsonChildrenKey': 'CONTAINS_SPECGRP',
                                    'childEntityType': 'specgrp'
                                    }
                                    }"/>
                            </xsl:map-entry>
                        </xsl:map>
                    </xsl:map-entry>
                    <xsl:map-entry key="'speclist'">
                        <xsl:map>
                            <xsl:map-entry key="'label'" select="'Speclist'"/>
                            <xsl:map-entry key="'cypherVar'" select="'speclist'"/>
                            <xsl:map-entry key="'children'">
                                <xsl:map>
                                    <xsl:map-entry key="'jsonChildrenKey'">LINK_TO_SPEC</xsl:map-entry>
                                    <xsl:map-entry key="'childEntityType'">link_to_spec</xsl:map-entry>
                                </xsl:map>
                             </xsl:map-entry>
                        </xsl:map>
                    </xsl:map-entry>
                    <xsl:map-entry key="'specgrp'">
                        <xsl:map>
                           <xsl:map-entry key="'label'" select="'Specgrp'"/>
                            <xsl:map-entry key="'cypherVar'" select="'specgrp'"/>
                            <xsl:map-entry key="'primaryKey'" select="'id'"/>
                            <xsl:map-entry key="'jsonKeyForPK'" select="'SPEC'"/>
                            <xsl:map-entry key="'properties'">
                                <xsl:map>
                                    <xsl:map-entry key="'contentModel'">CONTENT</xsl:map-entry>
                                </xsl:map>
                            </xsl:map-entry>
                            <xsl:map-entry key="'children'">
                                <xsl:map>
                                    <xsl:map-entry key="'jsonChildrenKey'">CONTAINS_PARAS</xsl:map-entry>
                                    <xsl:map-entry key="'childEntityType'">paragraph</xsl:map-entry>
                                </xsl:map>
                            </xsl:map-entry>
                        </xsl:map>
                    </xsl:map-entry>
                </xsl:map>
    </xsl:variable>
    
    
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
        <xsl:param name="parent-entity-type" as="xs:string?" required="no"/>
        <xsl:variable name="model" select="$my:graph-model($map-entity-type)"/>
        <xsl:variable name="parentModel" select="$my:graph-model($parent-entity-type)"/>
     <!-- ebb: This (below) may be too limited since we will have multiple possible parents for some node types
         <xsl:variable name="parent-model" select="$my:graph-model($model('parent'))"/>   -->     
        <xsl:sequence select="
        'MERGE ('||$parentModel('cypherVar')||')-[:'||$model('relationship')||']->('||$model('cypherVar')||')'"/>
    </xsl:function>
    
    <!-- FUNCTION FOR PROCESSING SEQUENCES (FOREACH) -->
    <xsl:function name="my:generate-foreach-block" as="xs:string">
        <xsl:param name="current-entity-type" as="xs:string"/>
        <xsl:param name="current-json-var" as="xs:string"/>
        
        <xsl:variable name="current-model" select="$my:graph-model($current-entity-type)"/>
        
        <xsl:for-each select="$current-model?children?*">
            <xsl:variable name="child-info" select="current()" as="map(*)"/>
            <xsl:variable name="child-entity-type" select="$child-info('childEntityType')"/>
            <xsl:variable name="child-model" select="$my:graph-model($child-entity-type)"/>
            <xsl:variable name="child-cypher-var" select="$child-model('cypherVar')"/>
            <xsl:variable name="child-json-var" select="$child-cypher-var || '_data'"/>
            
            <xsl:sequence select="'FOREACH ('||$child-json-var|| ' IN '||$current-json-var||'.'||$child-info('jsonChildrenKey')||' |'||
                $nltab||my:generate-node-merge($child-entity-type, $child-json-var)||$nltab||
                my:generate-relationship-merge($child-entity-type, $current-entity-type)||$nltab"/>  
        </xsl:for-each>
    </xsl:function>
   
<xsl:template match="/" mode="cypher">
    <xsl:result-document href="sandbox-cypher-import.cypher" method="text">
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
      
      // Create the single root Document node</xsl:text>
        <xsl:value-of select="$nltab"/>
      <xsl:value-of select="my:generate-node-merge('document', 'value')"/>
        <xsl:value-of select="$nltab"/>
      <xsl:text>
          // Process each Part (front, body)
      FOREACH (part_data in value.CONTAINS_PARTS |
        </xsl:text>
      <xsl:value-of select="my:generate-node-merge('part', 'part_data')"/>
       <xsl:value-of select="$newline"/>
        <xsl:value-of select="my:generate-relationship-merge('part')"/>
        <!--ebb: NOTE: second param of my:generate-relationship-merge() is not required. We want
            it when we have nodes that could have multiple different options for parents!
       -->
      <xsl:text>
          
          
     // OLD WRITTEN OUT FOR COMPARISON BELOW
     // FOREACH (part_data IN value.CONTAINS_PARTS |
     //   MERGE (part:Part {name: part_data.PART})
     //   MERGE (doc)-[:HAS_PART]->(part)
        
        </xsl:text>  
        
        
        
        
    </xsl:result-document>
</xsl:template>


</xsl:stylesheet>
