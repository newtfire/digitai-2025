<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns:eg ="http://www.tei-c.org/ns/Examples"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    exclude-result-prefixes="xs math"
    version="3.0">
    <!-- 2025-06-17 ebb: This XSLT performs an identity transformation on
        the English chapters of the P5 Guidelines 
        to remove their <specGrp> elements so that they are not attempting to pull included files.
        The output is stored in the newtfire digitai repo for use in processing to
        create a knowledge graph JSON structure in combination with the TEI p5Subset.
    -->
    <xsl:mode on-no-match="shallow-copy"/>
    
    <xsl:variable name="P5-chapters" as="document-node()+" select="collection('../../../TEIC/TEI/P5/Source/Guidelines/en/?select=*.xml')"/>
    <!-- Path on ebb's local computer from xslt folder in digitai up to the TEI repo. 
        We want a different cloud-based way of running this for an automated script.  -->
    
    <xsl:template match="/">
        <xsl:for-each select="$P5-chapters">
            <xsl:variable name="filename" as="xs:string" select="tokenize(base-uri(), '/')[last()]"/>
            <xsl:result-document method="xml" indent="yes" href="../p5-chapters/en-{format-date(current-date(), '[Y0001]-[M01]-[D01]')}/{$filename}">
                <xsl:apply-templates/>
            </xsl:result-document>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="specGrp"/>

</xsl:stylesheet>