<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:sfd="http://schemas.active-endpoints.com/appmodules/screenflow/2010/10/avosScreenflow.xsd"
    xmlns:rep="http://schemas.active-endpoints.com/appmodules/repository/2010/10/avrepository.xsd"
    version="2.0">
    <xsl:output method="xml" indent="yes" omit-xml-declaration="yes" /> 

    <!-- General template copies all xml nodes -->
    <xsl:template match="@*|node()" priority="-1">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" />
        </xsl:copy>
    </xsl:template>
    <!-- Remove Target location from Deployment -->
    <xsl:template match="sfd:deployment/sfd:targetLocation" priority="1"/>
    <!-- Remove Agent tag -->
    <xsl:template match="sfd:tags|rep:Tags">
        <xsl:copy>
            <xsl:value-of select="replace(.,'(,)?\.agent:\w+','')"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>
