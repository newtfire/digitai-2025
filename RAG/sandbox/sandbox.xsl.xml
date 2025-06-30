<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:my="https://my.namespace/for/function-definitions" exclude-result-prefixes="xs math"
    version="3.0">

    <xsl:output method="json" indent="yes"/>

    <xsl:variable name="sourceDoc" as="document-node()" select="doc('sandboxTest.xml')"/>

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
        <xsl:result-document href="sandboxTest.json">
            <xsl:map>
                <xsl:map-entry key="'DOC_TITLE'">SOURCE XML AS BASIS FOR A KNOWLEDGE
                    GRAPH</xsl:map-entry>
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


    </xsl:template>


</xsl:stylesheet>
