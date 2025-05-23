<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:con="http://schemas.informatica.com/socrates/data-services/2014/05/business-connector-model.xsd"
    xmlns:ave="http://schemas.active-endpoints.com/appmodules/screenflow/2011/06/avosHostEnvironment.xsd"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:saxon="http://saxon.sf.net/"
    exclude-result-prefixes="xsi con ave">
    <xsl:output
        method="xml"
        indent="yes"
        omit-xml-declaration="yes" />
    <!-- Identity transform -->
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" />
        </xsl:copy>
    </xsl:template>
    <!-- Sort con:action elements inside con:actions -->
    <xsl:template match="con:actions">
        <xsl:copy>
            <xsl:apply-templates select="con:action">
                <xsl:sort select="@name" />
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    <!-- Sort ave:processObject elements inside con:objects -->
    <xsl:template match="con:objects">
        <xsl:copy>
            <xsl:apply-templates select="ave:processObject">
                <xsl:sort select="@name" />
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    <!-- Sort ave:field elements inside ave:detail -->
    <xsl:template match="ave:detail">
        <xsl:copy>
            <xsl:apply-templates select="ave:field">
                <xsl:sort select="@name" />
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>