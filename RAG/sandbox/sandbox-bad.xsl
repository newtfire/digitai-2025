<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:array="http://www.w3.org/2005/xpath-functions/array"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:my="https://my.namespace/for/function-definitions" exclude-result-prefixes="xs math"
    version="3.0">

    <xsl:variable name="sourceDoc" as="document-node()" select="doc('sandboxTest.xml')"/>
    <xsl:variable name="newline" as="xs:string" select="'&#10;'"/>
    <xsl:variable name="tab" as="xs:string" select="'&#x9;'"/>
    <xsl:variable name="nltab" as="xs:string" select="$newline || $tab"/>

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
                    <xsl:map-entry key="'jsonVar'">value</xsl:map-entry>
                    <!-- ebb: Literally 'value' is the value of the document imported on load into neo4j. -->
                    <xsl:map-entry key="'primaryKey'">title</xsl:map-entry>
                    <xsl:map-entry key="'jsonKeyForPK'">DOC_TITLE</xsl:map-entry>
                    <xsl:map-entry key="'children'">
                        <xsl:sequence select="
                                array {
                                    map {
                                        'jsonChildrenKey': 'CONTAINS_PARTS',
                                        'childEntityType': 'part',
                                        'relationship': 'HAS_PART'(:,
                                        'isSequence': 'true()':)
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
                    <xsl:map-entry key="'properties'">
                        <xsl:map>
                            <xsl:map-entry key="'sequence'">SEQUENCE</xsl:map-entry>
                        </xsl:map>
                    </xsl:map-entry>
                    <xsl:map-entry key="'children'">
                        <xsl:sequence select="
                                array {
                                    map {
                                        'jsonChildrenKey': 'CONTAINS_CHAPTERS',
                                        'childEntityType': 'chapter',
                                        'relationship': 'HAS_CHAPTER'
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
                            <xsl:map-entry key="'sequence'">SEQUENCE</xsl:map-entry>
                        </xsl:map>
                    </xsl:map-entry>
                    <xsl:map-entry key="'children'">
                        <xsl:sequence select="
                                array {
                                    map {
                                        'jsonChildrenKey': 'CONTAINS_SECTIONS',
                                        'childEntityType': 'section',
                                        'relationship': 'HAS_SECTION'
                                    },
                                    map {
                                        'jsonChildrenKey': 'CONTAINS_PARAS',
                                        'childEntityType': 'paragraph',
                                        'relationship': 'HAS_PARAGRAPH'
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
                    <xsl:map-entry key="'properties'">
                        <xsl:map>
                            <xsl:map-entry key="'title'">SECTION</xsl:map-entry>
                            <xsl:map-entry key="'sequence'">SEQUENCE</xsl:map-entry>
                        </xsl:map>
                    </xsl:map-entry>
                    <xsl:map-entry key="'children'">
                        <xsl:sequence select="
                                array {
                                    map {
                                        'jsonChildrenKey': 'CONTAINS_SUBSECTIONS',
                                        'childEntityType': 'subsection',
                                        'relationship': 'HAS_SUBSECTION'
                                    },
                                    
                                    map {
                                        'jsonChildrenKey': 'CONTAINS_PARAS',
                                        'childEntityType': 'paragraph',
                                        'relationship': 'HAS_PARAGRAPH'
                                    }
                                }"/>
                    </xsl:map-entry>
                </xsl:map>
            </xsl:map-entry>
            <xsl:map-entry key="'subsection'">
                <xsl:map>
                    <xsl:map-entry key="'label'" select="'Subsection'"/>
                    <xsl:map-entry key="'cypherVar'" select="'subsection'"/>
                    <xsl:map-entry key="'primaryKey'" select="'id'"/>
                    <xsl:map-entry key="'jsonKeyForPK'" select="'ID'"/>
                    <xsl:map-entry key="'properties'">
                        <xsl:map>
                            <xsl:map-entry key="'title'">SUBSECTION</xsl:map-entry>
                            <xsl:map-entry key="'sequence'">SEQUENCE</xsl:map-entry>
                        </xsl:map>
                    </xsl:map-entry>
                    <xsl:map-entry key="'children'">
                        <xsl:sequence select="
                            array {
                            map {
                            'jsonChildrenKey': 'CONTAINS_NESTED_SUBSECTIONS',
                            'childEntityType': 'nestedsubsection',
                            'relationship': 'HAS_NESTED_SUBSECTION'
                            },
                            
                            map {
                            'jsonChildrenKey': 'CONTAINS_PARAS',
                            'childEntityType': 'paragraph',
                            'relationship': 'HAS_PARAGRAPH'
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
                    <xsl:map-entry key="'properties'">
                        <xsl:map>
                            <xsl:map-entry key="'title'">NESTEDSUBSECTION</xsl:map-entry>
                            <xsl:map-entry key="'sequence'">SEQUENCE</xsl:map-entry>
                        </xsl:map>
                    </xsl:map-entry>
                    <xsl:map-entry key="'children'">
                        <xsl:sequence select="
                            array {
                           (: map {
                            'jsonChildrenKey': 'CONTAINS_NESTED_SUBSECTIONS',
                            'childEntityType': 'nestedsubsection',
                            'relationship': 'HAS_NESTED_SUBSECTION'
                            },:)
                            
                            map {
                            'jsonChildrenKey': 'CONTAINS_PARAS',
                            'childEntityType': 'paragraph',
                            'relationship': 'HAS_PARAGRAPH'
                            }
                            }"/>
                    </xsl:map-entry>
                </xsl:map>
            </xsl:map-entry>

            <xsl:map-entry key="'paragraph'">
                <xsl:map>
                    <xsl:map-entry key="'label'" select="'Para'"/>
                    <xsl:map-entry key="'cypherVar'" select="'paragraph'"/>
                    <xsl:map-entry key="'properties'">
                        <xsl:map>
                            <xsl:map-entry key="'text'">PARASTRING</xsl:map-entry>
                            <xsl:map-entry key="'sequence'">SEQUENCE</xsl:map-entry>
                        </xsl:map>
                    </xsl:map-entry>
                    <xsl:map-entry key="'children'">
                        <xsl:sequence select="
                                array {
                                    map {
                                        'jsonChildrenKey': 'CONTAINS_SPECLIST',
                                        'childEntityType': 'speclist',
                                        'relationship': 'HAS_SPECLIST'
                                    },
                                    map {
                                        'jsonChildrenKey': 'CONTAINS_SPECGRP',
                                        'childEntityType': 'specgrp',
                                        'relationship': 'HAS_SPECGRP'
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
                        <xsl:sequence select="array{ 
                            map{
                                'jsonChildrenKey' : 'LINK_TO_SPEC',
                                'childEntityType': 'link_to_spec',
                                'relationship': 'REFERS_TO_SPECIFICATION'
                            }}"/>
                               
                             </xsl:map-entry>
                </xsl:map>
            </xsl:map-entry>
            <xsl:map-entry key="'link_to_spec'">
                <xsl:map>
                    <xsl:map-entry key="'label'" select="'LinkToSpec'"/>
                    <xsl:map-entry key="'cypherVar'" select="'link_to_spec'"/>
                    
                </xsl:map>
            </xsl:map-entry>
            <xsl:map-entry key="'specgrp'">
                <xsl:map>
                    <xsl:map-entry key="'label'" select="'Specgrp'"/>
                    <xsl:map-entry key="'cypherVar'" select="'specgrp'"/>
                    <xsl:map-entry key="'properties'" select="
                            map {
                                'title': 'SPECGRP'
                            }"/>
                    <xsl:map-entry key="'children'">
                        <xsl:sequence select="
                                array {
                                    map {
                                        'jsonChildrenKey': 'CONTAINS_SPECS',
                                        'childEntityType': 'specification',
                                        'relationship': 'HAS_SPEC'
                                    }
                                }"/>
                    </xsl:map-entry>

                </xsl:map>
            </xsl:map-entry>
            <xsl:map-entry key="'specification'">
                <xsl:map>
                    <xsl:map-entry key="'label'" select="'Spec'"/>
                    <xsl:map-entry key="'cypherVar'" select="'specification'"/>
                    <xsl:map-entry key="'primaryKey'" select="'id'"/>
                    <xsl:map-entry key="'jsonKeyForPK'" select="'SPEC'"/>
                    <xsl:map-entry key="'children'">
                                <xsl:sequence select="array{
                                    map{'contentModel': 'CONTENT',
                                        'childEntityType': 'contentmodel',
                                        'relationship': 'DEFINES_CONTENT_MODEL'},
                                    map{'jsonChildrenKey': 'CONTAINS_PARAS',
                                        'childEntityType': 'paragraph',
                                        'relationship': 'HAS_PARAGRAPH'
                                    }
                                    }"/>
                            </xsl:map-entry>
                </xsl:map>
            </xsl:map-entry>
            <xsl:map-entry key="'contentmodel'">
                <xsl:map>
                    <xsl:map-entry key="'label'" select="'Content'"/>
                    <xsl:map-entry key="'cypherVar'" select="'contentmodel'"/>
                    <xsl:map-entry key="'properties'" select="map{'rule':'RULE'}"/>

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
                <xsl:map-entry key="'SEQUENCE'">
                    <xsl:value-of select="count($section/preceding-sibling::div) + 1"/>
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
            <xsl:map-entry key="'SEQUENCE'">
                <xsl:value-of select="count($para/preceding-sibling::p) + 1"/>
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
                <xsl:map-entry key="'DOC_TITLE'">SOURCE XML AS BASIS FOR A KNOWLEDGE
                    GRAPH</xsl:map-entry>
                <xsl:variable name="parts" as="map(*)*">
                    <xsl:for-each select="$sourceDoc/*/*">
                        <xsl:map>
                            <xsl:map-entry key="'PART'">
                                <xsl:sequence select="current() ! name() ! normalize-space()"/>
                            </xsl:map-entry>
                            <xsl:map-entry key="'SEQUENCE'">
                                <xsl:choose>
                                    <xsl:when test="current() ! name() = 'front'">
                                        <xsl:value-of select="1"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="2"/>
                                    </xsl:otherwise>
                                </xsl:choose>
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

    <!-- FUNCTION TO CREATE GRAPH NODES -->
    <xsl:function name="my:generate-node-statement" as="xs:string">
        <xsl:param name="current-entity-type" as="xs:string"/>
        <xsl:param name="current-json-var" as="xs:string"/>

        <xsl:variable name="model" select="$my:graph-model($current-entity-type)"/>
        <xsl:variable name="cypher-var" select="$model('cypherVar')"/>

        <xsl:variable name="node-clause" as="xs:string">
            <xsl:choose>
                <xsl:when test="map:contains($model, 'primaryKey')">
                    <xsl:sequence select="
                            'MERGE (' || $cypher-var || ':' || $model('label') ||
                            ' {' || $model('primaryKey') || ': ' || $current-json-var || '.' || $model('jsonKeyForPK') || '})'
                            "/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="
                            'CREATE (' || $cypher-var || ':' || $model('label') || ')'
                            "/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="set-clauses" as="xs:string*">
            <xsl:if test="map:contains($model, 'properties')">
                <xsl:variable name="properties-map" select="$model('properties')"/>
                <xsl:for-each select="map:keys($properties-map)">
                    <xsl:variable name="prop-key" select="."/>
                    <xsl:variable name="json-key" select="$properties-map($prop-key)"/>
                    <xsl:sequence
                        select="$cypher-var || '.' || $prop-key || ' = ' || $current-json-var || '.' || $json-key"
                    />
                </xsl:for-each>
            </xsl:if>
        </xsl:variable>
        <xsl:variable name="full-set-statement" as="xs:string"
            select="string-join($set-clauses, ', ')"/>
        <xsl:sequence select="
                if (exists($set-clauses))
                then
                    $node-clause || ' SET ' || $full-set-statement
                else
                    $node-clause
                "/>
    </xsl:function>


    <!-- FUNCTION TO ESTABLISH GRAPH EDGES (RELATIONSHIP CONNECTIONS)-->
    <xsl:function name="my:generate-relationship-merge" as="xs:string">
        <xsl:param name="child-cypher-var" as="xs:string"/>
        <xsl:param name="parent-cypher-var" as="xs:string"/>
        <xsl:param name="relationship-name" as="xs:string"/>

        <xsl:sequence select="
                'MERGE (' || $parent-cypher-var || ')-[:' || $relationship-name || ']->(' || $child-cypher-var || ')'
                "/>
    </xsl:function>

    <!-- FUNCTION FOR PROCESSING SEQUENCES  -->
    <xsl:function name="my:create-next-links" as="xs:string*">
        <xsl:param name="node-label" as="xs:string"/>
        <xsl:param name="sort-property" as="xs:string"/>
        
        <xsl:sequence>
            <xsl:value-of select="$newline, '// Link sequential :', $node-label, ' nodes', $newline"/>
            <xsl:variable name="cypher" as="xs:string" select="
                'MATCH (n:'||$node-label||')
                WHERE n.'||$sort-property||' IS NOT NULL
                WITH n.'||$sort-property||', n
                ORDER BY n.'||$sort-property||'
                WITH collect(n) AS ordered_nodes
                UNWIND range(0, size(ordered_nodes) - 2) AS i
                WITH ordered_nodes[i] AS n1, ordered_nodes[i+1] AS n2
                MERGE (n1)-[:NEXT]->(n2)'
                "/>
            <xsl:sequence select="$cypher"/>
        </xsl:sequence>
    </xsl:function>
    
  
    
    <!-- GENERATE CYPHER FOR HIERARCHY FROM OUR GRAPH MODEL VARIABLE AT THE TOP OF THIS FILE -->
    <!-- The ONE recursive function to build the hierarchy -->
    <xsl:function name="my:generate-hierarchy" as="xs:string*">
        <xsl:param name="parent-cypher-var" as="xs:string"/>
        <xsl:param name="parent-json-var" as="xs:string"/>
        <xsl:param name="parent-model" as="map(*)"/>
        <xsl:param name="indent" as="xs:string"/>
        <xsl:param name="depth" as="xs:integer"/>
        
        <!-- Loop through each defined child relationship for the parent -->
       <xsl:if test="map:contains($parent-model, 'children')"> <xsl:for-each select="$parent-model?children?*">
            <xsl:variable name="child-info" select="current()"/>
            
            <xsl:variable name="child-type" select="$child-info('childEntityType')"/>
            <xsl:variable name="child-model" select="$my:graph-model($child-type)"/>
            <xsl:variable name="child-cypher-var" select="$child-model('cypherVar')"/>
            <!-- Create a unique variable name using the depth -->
            <xsl:variable name="child-json-var" select="concat($child-cypher-var, '_data_', $depth)"/>
            <xsl:variable name="relationship-type" select="$child-info('relationship')"/>
            <xsl:variable name="json-children-key" select="$child-info('jsonChildrenKey')"/>
            
            <!-- Generate the simple FOREACH loop -->
            <xsl:sequence select="$indent, 'FOREACH (', $child-json-var, ' IN ', $parent-json-var, '.', $json-children-key, ' |', $newline"/>
            <xsl:sequence select="$indent, $tab, my:generate-node-statement($child-type, $child-json-var), $newline"/>
            <xsl:sequence select="$indent, $tab, my:generate-relationship-merge($child-cypher-var, $parent-cypher-var, $relationship-type), $newline"/>
            
            <!-- RECURSION: Check if this new child has its own children -->
            <xsl:if test="exists($child-model?children)">
                <xsl:sequence select="my:generate-hierarchy($child-cypher-var, $child-json-var, $child-model, concat($indent, $tab), $depth + 1)"/>
            </xsl:if>
            
            <xsl:sequence select="$indent, ')', $newline"/>
        </xsl:for-each></xsl:if>
    </xsl:function>

    <xsl:template match="/" mode="cypher">
        <xsl:result-document href="sandbox-cypher-import.cypher" method="text">
            
            <!-- ebb: Define the variables in the graph model where the cypher script processing must begin. 
            Presumably it's the document mode, so that is what we've set here.-->
            <xsl:variable name="root-entity-type"  as="xs:string" select="'document'"/>
            <xsl:variable name="root-model" select="$my:graph-model($root-entity-type)"/>
            <xsl:variable name="root-cypher-var" select="$root-model('cypherVar')"/>
            <xsl:variable name="root-json-var" select="$root-model('jsonVar')"/>
            <xsl:variable name="root-pk" select="$root-model('primaryKey')"/>
            <xsl:variable name="root-json-pk" select="$root-model('jsonKeyForPK')"/>

            <xsl:text>
// ==== Generated by XSLT Transformation ====

// 1. SETUP: Create Constraints for Performance and Data Integrity
 CREATE CONSTRAINT IF NOT EXISTS FOR (d:Document) REQUIRE d.title IS UNIQUE;
 CREATE CONSTRAINT IF NOT EXISTS FOR (s:Section) REQUIRE s.id IS UNIQUE;
 CREATE CONSTRAINT IF NOT EXISTS FOR (spec:Specification) REQUIRE spec.name IS UNIQUE;

// 2. LOAD AND PROCESS: Load the JSON and start the recursive import
CALL apoc.load.json("file:///sandboxTest.json") YIELD value

// Create the root Document node
MERGE (doc:Document {title: 'SOURCE XML AS BASIS FOR A KNOWLEDGE GRAPH'})

</xsl:text>
            <xsl:sequence select="my:generate-node-statement($root-entity-type, $root-json-var), $newline, $newline"/>
        <!--    <xsl:value-of select="'MERGE ('||$root-cypher-var||':'||$root-model('label')|| ' {'||$root-json-var||'.'||$root-json-pk||'})'||$nltab"/>-->
            <xsl:sequence select="my:generate-hierarchy($root-cypher-var, $root-json-var, $root-model, '', 1)"/>
            
            

        </xsl:result-document>
    </xsl:template>


</xsl:stylesheet>
