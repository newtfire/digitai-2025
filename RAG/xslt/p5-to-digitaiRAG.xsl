<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns:eg ="http://www.tei-c.org/ns/Examples"
    xmlns:sch="http://purl.oclc.org/dsdl/schematron"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:nf="http://newtfire.org"
    exclude-result-prefixes="xs math"
    version="3.0">
    
    <xsl:output method="json" indent="yes"/>
    
    <!--GLOBAL VARIABLES -->
    <xsl:variable name="currentDateTime" as="xs:string" select="current-dateTime() ! string()"/>
    <xsl:variable name="P5" as="document-node()" select="doc('../p5.xml')"/>
    <xsl:variable name="P5-version" as="xs:string" select="$P5//edition/ref[2] ! normalize-space()"/>
    <xsl:variable name="P5-versionDate" as="xs:string" select="$P5//edition/date/@when ! normalize-space()"/>
    
    
    <!-- JSON-DATA functions -->
    <xsl:function name="nf:chapterMapper" as="map(*)*">
        <xsl:param name="part" as="element()+"/>
         <xsl:for-each select="$part">
             <xsl:map>
                 <xsl:map-entry key="'PART'"><xsl:sequence select="current()/name() ! normalize-space()"/></xsl:map-entry>
                 
             </xsl:map>
             
         </xsl:for-each>
    </xsl:function>
    
    
    <xsl:template match="/">
        <xsl:result-document href="../digitai-RAG-data.json" method="json" indent="yes"> 
            <xsl:map>
                <xsl:map-entry key="'DOCUMENT-TITLE'">THE TEI GUIDELINES AS BASIS FOR A KNOWLEDGE GRAPH</xsl:map-entry> 
                <xsl:map-entry key="'PREPARED-BY'">Digit-AI team: Elisa Beshero-Bondar, Hadleigh Jae Bills, and Alexander Charles Fisher</xsl:map-entry>
                <xsl:map-entry key="'SUPPORTING-INSTITUTION'">Penn State Erie, The Behrend College</xsl:map-entry>
                <xsl:map-entry key="'TEI_SOURCE-VERSION-NUMBER'"><xsl:value-of select="$P5-version"/></xsl:map-entry>
                <xsl:map-entry key="'TEI_SOURCE-OUTPUT-DATE'"><xsl:value-of select="$P5-versionDate"/></xsl:map-entry>
                <xsl:map-entry key="'THIS-JSON-DATETIME'"><xsl:value-of select="$currentDateTime"/></xsl:map-entry>
                <!--<xsl:map-entry key="'CONTAINS-PARTS'">
                    <xsl:sequence select="array { for $part in $P5/TEI/text/*[not(self::back)] return
                        $part ! name() ! normalize-space()}"/>
                </xsl:map-entry> -->
                <xsl:map-entry key="'CONTAINS-PARTS'"><xsl:sequence select="array { nf:chapterMapper($P5/TEI/text/*[not(self::back)])}"/></xsl:map-entry>

            </xsl:map>
        </xsl:result-document>
    </xsl:template>
    
</xsl:stylesheet>