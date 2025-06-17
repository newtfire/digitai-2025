<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns:eg ="http://www.tei-c.org/ns/Examples"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    exclude-result-prefixes="xs math eg"
    version="4.0">
    
    <xsl:output method="json" indent="yes"/>
    
    <xsl:template match="/">
        
        <xsl:variable name="chapterMaps" as="map(*)*">
            <xsl:apply-templates select="child::TEI[1]/text/*"/>
        </xsl:variable>
        
        <xsl:variable name="process" as="array(*)*">
          <xsl:sequence select="array{ for $section in (child::TEI[1]/text/*)
               return map {
               'section' : $section/name(),
               'CONTAINS-CHAPTERS': array { $chapterMaps

               }
               }
            }"/>
        </xsl:variable>
        
        <xsl:sequence select="map {
            'P5subset-text': current-dateTime(),
            'CONTAINS-SECTIONS' :  $process
            }"/>
      
        
 
    </xsl:template>
    
   <!-- <xsl:template match="test" as="map(*)">
        <xsl:sequence select="map {
            'lastBuildDate' : @lastBuildDate => xs:string()
            }"/>
    </xsl:template>-->

    
    <xsl:template match="text/*" as="map(*)*">
     
      
   <xsl:variable name="chapters" as="array(*)*">
            <xsl:sequence select="array {
                for $chap in child::div[@type='div1'] return
                map {
                  $chap/@xml:id : $chap/head/text()
                  }
                }
               "/> 
        </xsl:variable>
        
        <xsl:sequence select="map {
           
            'CONTAINS-CHAPTERS': $chapters
            }"/>

    </xsl:template>
    
</xsl:stylesheet>