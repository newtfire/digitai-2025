<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:array="http://www.w3.org/2005/xpath-functions/array"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:my="https://my.namespace/for/function-definitions" exclude-result-prefixes="xs math"
    version="4.0">

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
                    <xsl:map-entry key="'xpathPattern'">document()</xsl:map-entry>
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
                                        'relationship': 'HAS_PART',
                                        'isSequence': true()
                                    }
                                
                                }"/>
                    </xsl:map-entry>
                </xsl:map>
            </xsl:map-entry>
            <xsl:map-entry key="'part'">
                <xsl:map>
                    <xsl:map-entry key="'label'">Part</xsl:map-entry>
                    <xsl:map-entry key="'xpathPattern'">front | body</xsl:map-entry>
                    <xsl:map-entry key="'cypherVar'">part</xsl:map-entry>
                    <xsl:map-entry key="'primaryKey'">name</xsl:map-entry>
                    <xsl:map-entry key="'jsonKeyForPK'">PART</xsl:map-entry>
                 <!--   <xsl:map-entry key="'properties'">
                        <xsl:map>
                            <xsl:map-entry key="'sequence'">SEQUENCE</xsl:map-entry>
                        </xsl:map>
                    </xsl:map-entry>-->
                    <xsl:map-entry key="'children'">
                        <xsl:sequence select="
                                array {
                                    map {
                                        'jsonChildrenKey': 'CONTAINS_CHAPTERS',
                                        'childEntityType': 'chapter',
                                        'relationship': 'HAS_CHAPTER',
                                        'isSequence': true()
                                    }
                                }"/>
                    </xsl:map-entry>
                </xsl:map>
            </xsl:map-entry>
            <xsl:map-entry key="'chapter'">
                <xsl:map>
                    <xsl:map-entry key="'label'" select="'Chapter'"/>
                    <xsl:map-entry key="'xpathPattern'">div[@type='chapter']</xsl:map-entry>
                    <xsl:map-entry key="'cypherVar'" select="'chapter'"/>
                    <xsl:map-entry key="'primaryKey'" select="'chapter'"/>
                    <xsl:map-entry key="'jsonKeyForPK'" select="'CHAPTER'"/>
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
                                        'relationship': 'HAS_SECTION',
                                        'isSequence': true()
                                    },
                                    map {
                                        'jsonChildrenKey': 'CONTAINS_PARAS',
                                        'childEntityType': 'paragraph',
                                        'relationship': 'HAS_PARAGRAPH',
                                        'isSequence': true()
                                    }
                                }"/>
                    </xsl:map-entry>
                </xsl:map>
            </xsl:map-entry>

            <xsl:map-entry key="'section'">
                <xsl:map>
                    <xsl:map-entry key="'label'" select="'Section'"/>
                    <xsl:map-entry key="'xpathPattern'">div[@type='section']</xsl:map-entry>
                    <xsl:map-entry key="'cypherVar'" select="'section'"/>
                    <xsl:map-entry key="'primaryKey'" select="'section'"/>
                    <xsl:map-entry key="'jsonKeyForPK'" select="'SECTION'"/>
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
                                        'relationship': 'HAS_SUBSECTION',
                                        'isSequence': true()
                                    },
                                    
                                    map {
                                        'jsonChildrenKey': 'CONTAINS_PARAS',
                                        'childEntityType': 'paragraph',
                                        'relationship': 'HAS_PARAGRAPH',
                                        'isSequence': true()
                                    }
                                }"/>
                    </xsl:map-entry>
                </xsl:map>
            </xsl:map-entry>
            <xsl:map-entry key="'subsection'">
                <xsl:map>
                    <xsl:map-entry key="'label'" select="'Subsection'"/>
                    <xsl:map-entry key="'xpathPattern'">div[@type='section']</xsl:map-entry>
                    <xsl:map-entry key="'cypherVar'" select="'subsection'"/>
                    <xsl:map-entry key="'primaryKey'" select="'subsection'"/>
                    <xsl:map-entry key="'jsonKeyForPK'" select="'SUBSECTION'"/>
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
                            'jsonChildrenKey': 'CONTAINS_NESTED_SUBSECTIONS',
                            'childEntityType': 'nestedsubsection',
                            'relationship': 'HAS_NESTED_SUBSECTION',
                            'isSequence': true()
                            },
                            
                            map {
                            'jsonChildrenKey': 'CONTAINS_PARAS',
                            'childEntityType': 'paragraph',
                            'relationship': 'HAS_PARAGRAPH',
                            'isSequence': true()
                            }
                            }"/>
                    </xsl:map-entry>
                </xsl:map>
            </xsl:map-entry>
            <xsl:map-entry key="'nestedsubsection'">
                <xsl:map>
                    <xsl:map-entry key="'label'" select="'Nestedsubsection'"/>
                    <xsl:map-entry key="'xpathPattern'">div[@type='section']</xsl:map-entry>
                    <xsl:map-entry key="'cypherVar'" select="'nestedsubsection'"/>
                    <xsl:map-entry key="'primaryKey'" select="'nestedsubsection'"/>
                    <xsl:map-entry key="'jsonKeyForPK'" select="'NESTEDSUBSECTION'"/>
                    <xsl:map-entry key="'properties'">
                        <xsl:map>
                            <xsl:map-entry key="'title'">SECTION</xsl:map-entry>
                            <xsl:map-entry key="'sequence'">SEQUENCE</xsl:map-entry>
                        </xsl:map>
                    </xsl:map-entry>
                    <xsl:map-entry key="'children'">
                        <xsl:sequence select="
                            array {map {
                            'jsonChildrenKey': 'CONTAINS_PARAS',
                            'childEntityType': 'paragraph',
                            'relationship': 'HAS_PARAGRAPH',
                            'isSequence': true()
                            }
                            }"/>
                    </xsl:map-entry>
                </xsl:map>
            </xsl:map-entry>

            <xsl:map-entry key="'paragraph'">
                <xsl:map>
                    <xsl:map-entry key="'label'" select="'Para'"/>
                    <xsl:map-entry key="'xpathPattern'">p</xsl:map-entry>
                    <xsl:map-entry key="'cypherVar'" select="'paragraph'"/>
                    <xsl:map-entry key="'primaryKey'" select="'paragraph'"/>
                    <xsl:map-entry key="'jsonKeyForPK'" select="'PARASTRING'"/>
                    <xsl:map-entry key="'properties'">
                        <xsl:map>
                           <xsl:map-entry key="'sequence'">SEQUENCE</xsl:map-entry>
                            <xsl:map-entry key="'text'" select="'PARASTRING'"/>
                            <xsl:map-entry key="'spec_references'">
                                <xsl:map>
                                    <xsl:map-entry key="'isListComprehension'" select="true()"/>
                                    <xsl:map-entry key="'sourceArrayPath'" select="'CONTAINS_SPECLISTS.SPECLIST'"/>
                                    <xsl:map-entry key="'sourcePropertyKey'" select="'LINK_TO_SPEC'"/>
                                </xsl:map>
                            </xsl:map-entry>
                        </xsl:map>
                    </xsl:map-entry>
                    <xsl:map-entry key="'children'">
                        <xsl:sequence select="
                                array {
                                  (:  map {
                                        'jsonChildrenKey': 'CONTAINS_SPECLISTS',
                                        'childEntityType': 'speclist',
                                        'relationship': 'HAS_SPECLIST'
                                    },:)
                                    map {
                                        'jsonChildrenKey': 'CONTAINS_SPECGRPS',
                                        'childEntityType': 'specgrp',
                                        'relationship': 'HAS_SPECGRP'
                                    }
                                }"/>
                    </xsl:map-entry>
                </xsl:map>
            </xsl:map-entry>
          <!--  <xsl:map-entry key="'speclist'">
                <xsl:map>
                    <xsl:map-entry key="'label'" select="'Speclist'"/>
                    <xsl:map-entry key="'xpathPattern'">specList</xsl:map-entry>
                    <xsl:map-entry key="'cypherVar'" select="'speclist'"/>
                    <xsl:map-entry key="'primaryKey'">name</xsl:map-entry>
                    <xsl:map-entry key="'jsonKeyForPK'">SPECLIST</xsl:map-entry>
                    <xsl:map-entry key="'children'">
                        <xsl:sequence select="array{ 
                            map{
                                'jsonChildrenKey' : 'LINK_TO_SPEC',
                                'childEntityType': 'link_to_spec',
                                'relationship': 'REFERS_TO_SPECIFICATION'
                            }}"/>
                               
                             </xsl:map-entry>
                </xsl:map>
            </xsl:map-entry>-->
        <!--    <xsl:map-entry key="'link_to_spec'">
                <xsl:map>
                    <xsl:map-entry key="'label'" select="'LinkToSpec'"/>
                    <xsl:map-entry key="'xpathPattern'">specDesc</xsl:map-entry>
                    <xsl:map-entry key="'cypherVar'" select="'link_to_spec'"/>
                    <xsl:map-entry key="'primaryKey'">name</xsl:map-entry>
                    <xsl:map-entry key="'jsonKeyForPK'">LINK_TO_SPEC</xsl:map-entry>
                </xsl:map>
            </xsl:map-entry>-->
            <xsl:map-entry key="'specgrp'">
                <xsl:map>
                    <xsl:map-entry key="'label'" select="'Specgrp'"/>
                    <xsl:map-entry key="'xpathPattern'">specGrp</xsl:map-entry>
                    <xsl:map-entry key="'cypherVar'" select="'specgrp'"/>
                    <xsl:map-entry key="'primaryKey'">name</xsl:map-entry>
                    <xsl:map-entry key="'jsonKeyForPK'">SPECGRP</xsl:map-entry>
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
                    <xsl:map-entry key="'xpathPattern'">spec</xsl:map-entry>
                    <xsl:map-entry key="'cypherVar'" select="'specification'"/>
                    <xsl:map-entry key="'primaryKey'" select="'name'"/>
                    <xsl:map-entry key="'jsonKeyForPK'" select="'SPEC'"/>
                    <xsl:map-entry key="'children'">
                                <xsl:sequence select="array{
                                    map{'jsonChildrenKey': 'HAS_CONTENT',
                                        'childEntityType': 'contentmodel',
                                        'relationship': 'DEFINES_CONTENT_MODEL'},
                                    map{'jsonChildrenKey': 'CONTAINS_TERMINAL_PARAS',
                                        'childEntityType': 'terminal_paragraph',
                                        'relationship': 'HAS_TERMINAL_PARA',
                                        'isSequence': true()
                                    }
                                    }"/>
                            </xsl:map-entry>
                </xsl:map>
            </xsl:map-entry>
            <xsl:map-entry key="'terminal_paragraph'">
                <xsl:map>
                    <xsl:map-entry key="'label'">Para</xsl:map-entry>
                    <xsl:map-entry key="'cypherVar'">terminal_paragraph</xsl:map-entry>
                    <xsl:map-entry key="'properties'">
                        <xsl:map>
                            <xsl:map-entry key="'text'">PARASTRING</xsl:map-entry>
                            <xsl:map-entry key="'sequence'">SEQUENCE</xsl:map-entry>
                        </xsl:map>
                    </xsl:map-entry>
                    
                </xsl:map>
            </xsl:map-entry>
            <xsl:map-entry key="'contentmodel'">
                <xsl:map>
                    <xsl:map-entry key="'label'" select="'Content'"/>
                    <xsl:map-entry key="'xpathPattern'">contentModel</xsl:map-entry>
                    <xsl:map-entry key="'cypherVar'" select="'contentmodel'"/>
                    <xsl:map-entry key="'primaryKey'" select="'name'"/>
                    <xsl:map-entry key="'jsonKeyForPK'" select="'CONTENT'"/>
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
                        <xsl:map-entry key="'CONTAINS_SPECGRPS'">
                            <xsl:sequence select="array {my:specGrpMapper($para/specGrp)}"/>
                        </xsl:map-entry>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:map-entry key="'CONTAINS_SPECLISTS'">
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
                            <xsl:sequence select="map{ 'SPECLIST': array {$specRefs}}"/>
                        </xsl:map-entry>

                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
        </xsl:map>
    </xsl:function>

    <xsl:function name="my:specGrpMapper" as="map(*)*">
        <xsl:param name="specGrp" as="element()"/>
        <xsl:variable name="specs" as="element()+" select="$specGrp/spec"/>
        <xsl:variable name="specMaps" as="map(*)*">
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
        </xsl:variable>
        <xsl:map>
            <xsl:map-entry key="'SPECGRP'" select="array{$specMaps}"/>
        </xsl:map>
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
        <xsl:param name="cypher-var" as="xs:string"/> 
        <xsl:param name="current-json-var" as="xs:string"/>


        <xsl:variable name="model" select="$my:graph-model($current-entity-type)"/>
        <xsl:variable name="label" select="$model('label')"/>
      <!--  <xsl:variable name="cypher-var" as="xs:string" select="$model('cypherVar') ! string()"/>-->


        <xsl:variable name="node-clause" as="xs:string">
            <xsl:choose>
                <xsl:when test="map:contains($model, 'primaryKey')">
                  <xsl:variable name="current-cypher-pk" as="xs:string" select="$model('primaryKey') ! string()"/>
                    <xsl:sequence select="
                            'MERGE (' || $cypher-var|| ':' || $label ||
                            ' {' || $current-cypher-pk || ': ' ||$current-json-var||'.' || $model('jsonKeyForPK') || '})'
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
                   <!-- <xsl:sequence
                        select="$cypher-var||'.' || $prop-key || ' = ' || $current-json-var || '.' || $json-key"
                    />-->
                    <xsl:choose>
                        <xsl:when test="$json-key instance of map(*) and $json-key?isListComprehension">
                            <xsl:sequence select="
                                $cypher-var||'.'||$prop-key||' = [x IN '||$current-json-var||'.'||$json-key('sourceArrayPath')||' WHERE x IS NOT NULL | x.'||$json-key('sourcePropertyKey')||']'
                                "/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence select="
                                $cypher-var||'.'||$prop-key||' = '||$current-json-var||'.'||$json-key
                                "/>
                        </xsl:otherwise>
                    </xsl:choose>
                    
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
    
    <!-- FUNCTION TO ESTABLISH A SINGLE FOREACH STATEMENT (ONE FOR EACH CHILDTYPE OF A NODE) -->
    <!-- ebb: Fire this function while looking down at the children while processing the current node. -->
    <xsl:function name="my:generate-foreach-statement" as="xs:string">
        <xsl:param name="child-type" as="xs:string"/>
        <xsl:param name="parent-cypher-var" as="xs:string"/>
        <xsl:param name="json-children-key" as="xs:string"/><!-- ebb: for example: "CONTAINS_PARTS"  -->
        <xsl:value-of select="$nltab||'FOREACH ('||$child-type||'_data'||' IN '||$parent-cypher-var||'_data.'||$json-children-key||' |'||$nltab"/>
    </xsl:function>


    <!-- FUNCTION TO ESTABLISH EACH GRAPH EDGES (RELATIONSHIP CONNECTIONS)-->
    <xsl:function name="my:generate-relationship-merge" as="xs:string+">
        <xsl:param name="child-cypher-var" as="xs:string"/>
        <xsl:param name="parent-cypher-var" as="xs:string"/>
        <xsl:param name="relationship-name" as="xs:string"/>
   

        <xsl:sequence select="
                'MERGE (' || $parent-cypher-var || ')-[:' || $relationship-name || ']->(' || $child-cypher-var || ')'
                "/>
    </xsl:function>

    <!-- FUNCTION FOR PROCESSING SEQUENCES OF SIBLINGS  -->
    <xsl:function name="my:create-next-links" as="xs:string*">
        <xsl:param name="parent-label" as="xs:string"/>
        <xsl:param name="child-label" as="xs:string"/>
        <xsl:param name="relationship" as="xs:string"/>
        <xsl:param name="sort-property" as="xs:string"/>
        
        <xsl:variable name="cypher" as="xs:string" select="
            'MATCH (parent:'||$parent-label||')-[:'||$relationship||']->(child:'||$child-label||')
            WHERE child.'||$sort-property||' IS NOT NULL
            WITH parent, child ORDER BY child.'||$sort-property||'
            WITH parent, collect(child) AS ordered_children
            UNWIND range(0, size(ordered_children) - 2) AS i
            WITH ordered_children[i] AS n1, ordered_children[i+1] AS n2
            MERGE (n1)-[:NEXT]->(n2)'
            "/>
        <xsl:sequence select="$newline, '// Link sequential :', $child-label, ' nodes within each :', $parent-label, $newline, $cypher"/>
    </xsl:function>
    
  
    
    <!-- GENERATE CYPHER FROM THE SOURCE XML AND OUR GRAPH MODEL VARIABLE AT THE TOP OF THIS FILE -->
  

    <xsl:template match="/" mode="cypher">
        <xsl:variable name="currentXMLNode" as="document-node()" select="current()"/>
        <xsl:result-document href="sandbox-cypher-import.cypher" method="text">
            
            <!-- ebb: Define the variables in the graph model where the cypher script processing must begin. 
            Presumably it's the document mode, so that is what we've set here.-->
            <xsl:variable name="root-entity-type"  as="xs:string" select="'document'"/>
            <xsl:variable name="root-model" select="$my:graph-model($root-entity-type)"/>
            <xsl:variable name="root-cypher-var" select="$root-model('cypherVar') ! string()" as="xs:string"/>
            <xsl:variable name="root-json-var" select="$root-model('jsonVar') ! string()"/>
            <xsl:variable name="root-pk" select="$root-model('primaryKey') ! string()"/>
            <xsl:variable name="root-json-pk" select="$root-model('jsonKeyForPK') ! string()"/>

            <xsl:text>
// ==== Generated by XSLT Transformation ====

// 1. SETUP: Create Constraints for Performance and Data Integrity
 CREATE CONSTRAINT IF NOT EXISTS FOR (d:Document) REQUIRE d.title IS UNIQUE;
 CREATE CONSTRAINT IF NOT EXISTS FOR (s:Section) REQUIRE s.id IS UNIQUE;
 CREATE CONSTRAINT IF NOT EXISTS FOR (spec:Specification) REQUIRE spec.name IS UNIQUE;

// 2. LOAD AND PROCESS: Load the JSON and start the recursive import
CALL apoc.load.json("https://raw.githubusercontent.com/newtfire/digitai/refs/heads/ebb-json/RAG/sandbox/sandboxTest.json") YIELD value as doc_data

// Create the root Document node
MERGE (doc:Document {title: 'SOURCE XML AS BASIS FOR A KNOWLEDGE GRAPH'})

</xsl:text>
          
            <xsl:call-template name="my:process-children">
                <xsl:with-param name="parent_cypher_var" select="$root-model('cypherVar')"/>
                <xsl:with-param name="parent_json_var" select="'doc_data'"/>
                <xsl:with-param name="children_to_process" select="$root-model?children?*"/>
                <xsl:with-param name="indent" select="''"/>
                <xsl:with-param name="depth" select="1"/>
            </xsl:call-template>      

            <xsl:text>
;

// STEP 2: Create sequential :NEXT relationships
</xsl:text>
            
        <!--    <xsl:sequence select="my:create-next-links('part', 'sequence'), ';'"/>
            <xsl:sequence select="my:create-next-links('section', 'sequence'), ';'"/>-->
            
            <xsl:for-each select="map:keys($my:graph-model)[exists($my:graph-model(.)?children?*[?isSequence = true()])]">
                
                <xsl:variable name="parent-model" select="$my:graph-model(.)"/>
                
                <xsl:for-each select="$parent-model?children?*[?isSequence = true()]">
                    <xsl:variable name="child-info" select="."/>
                    <xsl:variable name="child-model" select="$my:graph-model($child-info?childEntityType)"/>
                    <xsl:sequence select="my:create-next-links(
                        $parent-model('label'),
                        $child-model('label'),
                        $child-info('relationship'),
                        'sequence'
                        ), ';'"/>
                </xsl:for-each>
                
            </xsl:for-each>
            

        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="my:process-children">
        <xsl:param name="parent_cypher_var" as="xs:string"/>
        <xsl:param name="parent_json_var" as="xs:string"/>
        <xsl:param name="children_to_process" as="map(*)*"/>
        <xsl:param name="indent" as="xs:string"/>
        <xsl:param name="depth" as="xs:integer"/>
        
        <xsl:for-each select="$children_to_process">
            <xsl:variable name="child-info" select="."/>
            
            <xsl:variable name="child-type" select="$child-info('childEntityType')"/>
            <xsl:variable name="child-model" select="$my:graph-model($child-type)"/>
            
          <xsl:if test="$child-type != 'specgrp'">  
            <xsl:variable name="child-cypher-var" select="$child-model('cypherVar')||'_'||$depth"/>
            <xsl:variable name="child-json-var" select="$child-cypher-var||'_data_'||$depth"/>
            <xsl:variable name="relationship" select="$child-info('relationship')"/>
            <xsl:variable name="json-key" select="$child-info('jsonChildrenKey')"/>
            
          <!--  <xsl:sequence select="$newline, $indent, 'WITH ', $parent_cypher_var, ', ', $parent_json_var"/>-->
            <xsl:sequence select="$newline, $indent, 'FOREACH (', $child-json-var, ' IN ', $parent_json_var, '.', $json-key, ' |'"/>
            <xsl:sequence select="$newline, $indent, $tab, my:generate-node-statement($child-type, $child-cypher-var, $child-json-var)"/>
            <xsl:sequence select="$newline, $indent, $tab, 'MERGE (', $parent_cypher_var, ')-[:', $relationship, ']->(', $child-cypher-var, ')'"/>
            
           <xsl:if test="exists($child-model?children)">
                <xsl:call-template name="my:process-children">
                    <xsl:with-param name="parent_cypher_var" select="$child-cypher-var"/>
                    <xsl:with-param name="parent_json_var" select="$child-json-var"/>
                    <xsl:with-param name="children_to_process" select="$child-model?children?*"/>
                    <xsl:with-param name="indent" select="concat($indent, $tab)"/>
                    <xsl:with-param name="depth" select="$depth + 1"/>
                </xsl:call-template>
            </xsl:if>
            
            <xsl:sequence select="$newline, $indent, ')'"/>
          </xsl:if>
            <xsl:if test="$child-type = 'specgrp'"> 
                <xsl:variable name="specgrp_model" select="$my:graph-model('specgrp')"/>
                <xsl:variable name="specgrp_cypher_var" select="concat($specgrp_model('cypherVar'), '_', $depth)"/>
                <xsl:variable name="specgrp_json_var" select="concat($specgrp_model('cypherVar'), '_data_', $depth)"/>
                
                <xsl:variable name="spec_model" select="$my:graph-model('specification')"/>
                <xsl:variable name="spec_cypher_var" select="concat($spec_model('cypherVar'), '_', $depth)"/>
                <xsl:variable name="spec_json_var" select="concat($spec_model('cypherVar'), '_item_', $depth)"/>
                
                <xsl:variable name="cypher-block">
                    <xsl:sequence select="$newline, $indent, 'FOREACH (', $specgrp_json_var, ' IN ', $parent_json_var, '.CONTAINS_SPECGRPS |'"/>
                    <xsl:sequence select="$newline, $indent, $tab, 'CREATE (', $specgrp_cypher_var, ':', $specgrp_model('label'), ')'"/>
                    <xsl:sequence select="$newline, $indent, $tab, 'MERGE (', $parent_cypher_var, ')-[:HAS_SPECGRP]->(', $specgrp_cypher_var, ')'"/>
                    <xsl:sequence select="$newline, $indent, $tab, 'FOREACH (', $spec_json_var, ' IN ', $specgrp_json_var, '.SPECGRP |'"/>
                    <xsl:sequence select="$newline, $indent, $tab, $tab, 'MERGE (', $spec_cypher_var, ':', $spec_model('label'), ' {name: ', $spec_json_var, '.SPEC})'"/>
                    <xsl:sequence select="$newline, $indent, $tab, $tab, 'MERGE (', $specgrp_cypher_var, ')-[:HAS_SPEC]->(', $spec_cypher_var, ')'"/>
                    
                    <xsl:if test="exists($spec_model?children)">
                        <xsl:call-template name="my:process-children">
                            <xsl:with-param name="parent_cypher_var" select="$spec_cypher_var"/>
                            <xsl:with-param name="parent_json_var" select="$spec_json_var"/>
                            <xsl:with-param name="children_to_process" select="$spec_model?children?*"/>
                            <xsl:with-param name="indent" select="concat($indent, $tab, $tab)"/>
                            <xsl:with-param name="depth" select="$depth + 1"/>
                        </xsl:call-template>
                    </xsl:if>
                    
                    <xsl:sequence select="$newline, $indent, $tab, ')'"/>
                    <xsl:sequence select="$newline, $indent, ')'"/>
                </xsl:variable>
                <xsl:sequence select="$cypher-block"/>
                
            </xsl:if>
        </xsl:for-each>
        
     
    </xsl:template>
    
    
 

</xsl:stylesheet>
