<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:sfd="http://schemas.active-endpoints.com/appmodules/screenflow/2010/10/avosScreenflow.xsd"
    version="2.0">
    <xsl:output method="xml" indent="yes" omit-xml-declaration="yes" />
    <!-- Tracing suspend on can be true/false
    -->
    <xsl:param name="suspendOnFault">true</xsl:param>  


    <!-- General template copies all xml nodes -->
    <xsl:template match="@*|node()" priority="-1">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" />
        </xsl:copy>
    </xsl:template>
    
    
    <xsl:template match="sfd:deployment/@suspendOnFault">
        <xsl:attribute name="suspendOnFault">
            <xsl:value-of select="$suspendOnFault"/>
        </xsl:attribute>
    </xsl:template>
    
    <xsl:template match="sfd:deployment[not(@suspendOnFault)]">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="suspendOnFault">
                <xsl:value-of select="$suspendOnFault"/>
             </xsl:attribute>
            <xsl:apply-templates select="node()"/> 
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>
