<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:sfd="http://schemas.active-endpoints.com/appmodules/screenflow/2010/10/avosScreenflow.xsd"
    xmlns:rep="http://schemas.active-endpoints.com/appmodules/repository/2010/10/avrepository.xsd"
    xmlns:con="http://schemas.informatica.com/socrates/data-services/2014/04/avosConnections.xsd"
    xmlns:bcm="http://schemas.informatica.com/socrates/data-services/2014/05/business-connector-model.xsd"
    xmlns:po ="http://schemas.active-endpoints.com/appmodules/screenflow/2011/06/avosHostEnvironment.xsd"
    version="2.0">
    <xsl:output method="xml" indent="yes"  omit-xml-declaration="yes"  />
    <xsl:param name="designVersion">1.0</xsl:param>    

    <!-- General template copies all xml nodes -->
    <xsl:template match="@*|node()" priority="-1">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" />
        </xsl:copy>
    </xsl:template>
    
    <!-- Update Object and metadata Descriptions with Version information -->
    <xsl:template match="rep:Description|rep:Entry/*/sfd:description|con:connection/con:description|bcm:businessConnector/bcm:description">
        <xsl:copy>
            <xsl:choose> 
                <xsl:when test="empty(./text())"> 
                    <xsl:value-of select="concat('version: ',$designVersion)"/>
                </xsl:when>
                <xsl:when test="exists(../rep:Entry/po:processObject)"> 
                    <xsl:value-of select="string-join((normalize-space(replace(./text(),'&#10;',' ')),'version:',$designVersion),' ')"/>
                </xsl:when>
                <xsl:when test="matches(./text(),'(.*)(version|Version):? *(\d+)(\.\d+)*(.*)( )?(.*)?')"> 
                    <xsl:value-of select="concat(normalize-space(replace(./text(),'(.*)(version|Version):? *(\d+)(\.\d+)*( )?(.*)?','$1$6')),'&#10;version: ',$designVersion)"/> 
                </xsl:when> 
                <xsl:otherwise> 
                    <xsl:value-of select="concat(./text(),'&#10;version: ',$designVersion)"/> 
                </xsl:otherwise> 
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    
    <!-- Process Objects support only line description import strips content after line break -->
    <xsl:template match="po:description">
        <xsl:copy>
            <xsl:value-of select="string-join((normalize-space(replace(./text(),'&#10;',' ')),'version:',$designVersion),' ')"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>
