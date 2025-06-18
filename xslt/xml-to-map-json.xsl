<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    exclude-result-prefixes="xs math"
    version="3.0">
    
    <xsl:output method="json" indent="yes"/>
    
    <xsl:template match="/">
        <xsl:variable name="elementTester" as="element()">
            <test lastBuildDate="{current-dateTime()}"/>
        </xsl:variable>

            <xsl:apply-templates select="$elementTester"/>
     
    
    </xsl:template>
    
    <xsl:template match="test" as="map(*)">
        <xsl:sequence select="map {
            @* ! name() : @lastBuildDate => xs:string()
            }"/>
    </xsl:template>
    
    
</xsl:stylesheet>