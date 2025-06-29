<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns:eg ="http://www.tei-c.org/ns/Examples"
    xmlns:sch="http://purl.oclc.org/dsdl/schematron"
    xmlns:array="http://www.w3.org/2005/xpath-functions/array"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:nf="http://newtfire.org"
    exclude-result-prefixes="xs math"
    version="3.0">
    
    
    
    <!--GLOBAL VARIABLES -->
    <xsl:variable name="currentDateTime" as="xs:string" select="current-dateTime() ! string()"/>
    <xsl:variable name="P5" as="document-node()" select="doc('../p5.xml')"/>
    <xsl:variable name="P5-version" as="xs:string" select="$P5//edition/ref[2] ! normalize-space()"/>
    <xsl:variable name="P5-versionDate" as="xs:string" select="$P5//edition/date/@when ! normalize-space()"/>
    
    <!-- JSON MAPPING TO KEYS -->
    <!-- GRAPH NODE KEYS -->
    <xsl:variable name="DOCUMENT_TITLE" as="xs:string" select="'DOCUMENT_TITLE'"/>
    <xsl:variable name="PREPARED_BY" as="xs:string" select="'PREPARED_BY'"/>
    <xsl:variable name="SUPPORTING_INSTITUTION" as="xs:string" select="'SUPPORTING_INSTITUTION'"/>
    <xsl:variable name="TEI_SOURCE_VERSION_NUMBER" as="xs:string" select="'TEI_SOURCE_VERSION_NUMBER'"/>
    <xsl:variable name="TEI_SOURCE_OUTPUT_DATE" as="xs:string" select="'TEI_SOURCE_OUTPUT_DATE'"/>
    <xsl:variable name="THIS_JSON_DATETIME" as="xs:string" select="'THIS_JSON_DATETIME'"/>
    <xsl:variable name="PART" as="xs:string" select="'PART'"/>
    <xsl:variable name="CHAPTER" as="xs:string" select="'CHAPTER'"/>
    <xsl:variable name="SUBSECTION" as="xs:string" select="'SUBSECTION'"/>
    <xsl:variable name="NAME" as="xs:string" select="'NAME'"/>
    <xsl:variable name="ID" as="xs:string" select="'ID'"/>
    
    <!-- GRAPH RELATIONSHIP KEYS -->
    <xsl:variable name="CONTAINS_PARTS" as="xs:string" select="'CONTAINS_PARTS'"/>
    <xsl:variable name="CONTAINS_CHAPTERS" as="xs:string" select="'CONTAINS_CHAPTERS'"/>
    <xsl:variable name="CONTAINS_SECTIONS" as="xs:string" select="'CONTAINS_SECTIONS'"/>
    <xsl:variable name="CONTAINS_SUBSECTIONS" as="xs:string" select="'CONTAINS_SUBSECTIONS'"/>
    <xsl:variable name="CONTAINS_PARAS" as="xs:string" select="'CONTAINS_PARAS'"/>
        
    
    
    
    <!-- JSON-DATA functions -->
    <!-- ebb: An accumulator function suggested on the XML Slack for numbering, in case we want it. Not sure we need it? -->
    <xsl:function name="nf:mapToArray" as="array(*)*">
        <xsl:param name="sourceMap" as="map(*)"/>
            <xsl:sequence select="fold-left(1 to map:size($sourceMap), [], function($acc as array(*), $index as xs:integer)
                {array:append($acc, $sourceMap($index))
                })"/>   
        
    </xsl:function>
    <xsl:function name="nf:chapterMapper" as="map(*)*">
        <xsl:param name="part" as="element()+"/>
         <xsl:for-each select="$part">
             <xsl:map>
                 <xsl:map-entry key="$PART"><xsl:sequence select="current() ! name() ! normalize-space()"/></xsl:map-entry>
                <xsl:variable name="chapterMaps" as="map(*)*"> 
                    <xsl:for-each select="current()/div[not(@xml:id='DEPRECATIONS') and not(starts-with(@xml:id, 'REF-'))]">
                     <xsl:variable name="chap" as="element(div)" select="current()"/>
                     <xsl:map>
                         <xsl:map-entry key="$CHAPTER"><xsl:value-of select="$chap/head ! normalize-space()"/></xsl:map-entry>
                         <xsl:map-entry key="$ID"><xsl:value-of select="$chap/@xml:id ! normalize-space()"/></xsl:map-entry>
      
                         <!--</xsl:map-entry>-->
                         <!--   <xsl:if test="current()[p]">
                                        <xsl:map-entry key="$CONTAINS_PARAS"><xsl:sequence select="array{nf:paraPuller(current()/p) }"/></xsl:map-entry>
                                    </xsl:if>-->
                      </xsl:map>
                    </xsl:for-each>
                 </xsl:variable> 
                 <xsl:map-entry key="$CONTAINS_CHAPTERS"><xsl:sequence select="array{ $chapterMaps}"/></xsl:map-entry>
             </xsl:map>
         </xsl:for-each>
    </xsl:function>
    <xsl:function name="nf:DivPuller" as="map(*)*">
        <xsl:param name="div" as="element()"/>
        <xsl:param name="sectionLevel" as="xs:string"/>
        <xsl:map>
            <xsl:map-entry key="$NAME"><xsl:value-of select="$div/head ! normalize-space()"/></xsl:map-entry>
            <xsl:map-entry key="$ID"><xsl:value-of select="$div/@xml:id ! normalize-space()"/></xsl:map-entry>
            


           <!-- Are you a section with nested subsections? If so, continue processing those subsections. -->
            <xsl:if test="$div/div[head]">
                <xsl:map-entry key="'CONTAINS-'||$sectionLevel||'S'">
              
                       <xsl:sequence select="array { for $subd in $div/div[head] return nf:DivPuller($subd, 'NESTED-SUBSECTION')} "/>
                </xsl:map-entry>
           </xsl:if>
         
       </xsl:map>
    </xsl:function>
    
<!--    <xsl:template match="/" mode="json-schema">
        <xsl:result-document href="../digitai-RAG-json.schema">
            
            
            
        </xsl:result-document>
    </xsl:template>-->
    
    <xsl:template match="/" mode="cypher">
        <xsl:result-document href="../digitai-RAG-cypher.cypher" method="text" indent="yes"> 
            
             CALL apoc.load.json("file:///digitai-p5.json") YIELD value AS json_data
             title: json_data. ,
             preparedBy: json_data.<xsl:value-of select="$PREPARED_BY"/>,
            teiSourceVersion: json_data.<xsl:value-of select="$TEI_SOURCE_VERSION_NUMBER"/>,
             teiSourceOutputDate: json_data.<xsl:value-of select="$TEI_SOURCE_OUTPUT_DATE"/>,
             thisJsonDatetime: json_data.<xsl:value-of select="$THIS_JSON_DATETIME"/>
             FOREACH (chapter_data IN 
            
            
            <!-- CONNECT ELEMENTS and ATTRIBUTES MENTIONED to their SPECS -->
           
            
            
            
        </xsl:result-document>
    </xsl:template>
    
    
    <xsl:template match="/">
        <xsl:result-document href="../digitai-RAG-data.json" method="json" indent="yes"> 
            <xsl:map>
                <xsl:map-entry key="$DOCUMENT_TITLE">THE TEI GUIDELINES AS BASIS FOR A KNOWLEDGE GRAPH</xsl:map-entry> 
                <xsl:map-entry key="$PREPARED_BY">Digit-AI team: Elisa Beshero-Bondar, Hadleigh Jae Bills, and Alexander Charles Fisher</xsl:map-entry>
                <xsl:map-entry key="$SUPPORTING_INSTITUTION">Penn State Erie, The Behrend College</xsl:map-entry>
                <xsl:map-entry key="$TEI_SOURCE_VERSION_NUMBER"><xsl:value-of select="$P5-version"/></xsl:map-entry>
                <xsl:map-entry key="$TEI_SOURCE_OUTPUT_DATE"><xsl:value-of select="$P5-versionDate"/></xsl:map-entry>
                <xsl:map-entry key="$THIS_JSON_DATETIME"><xsl:value-of select="$currentDateTime"/></xsl:map-entry>
                   <xsl:map-entry key="$CONTAINS_PARTS">
                    <xsl:sequence select="array { nf:chapterMapper($P5/TEI/text/*[not(self::back)])}"/>
                </xsl:map-entry>

            </xsl:map>
        </xsl:result-document>
        <xsl:apply-templates select="/" mode="cypher"/>
    </xsl:template>
    
</xsl:stylesheet>