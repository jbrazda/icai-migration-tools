<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:sfd="http://schemas.active-endpoints.com/appmodules/screenflow/2010/10/avosScreenflow.xsd"
    xmlns:rep="http://schemas.active-endpoints.com/appmodules/repository/2010/10/avrepository.xsd"
    version="2.0">
    <xsl:output method="xml" indent="yes"  omit-xml-declaration="yes"  />
    <xsl:param name="targetLocation">agent01</xsl:param>    

    <!-- General template copies all xml nodes -->
    <xsl:template match="@*|node()" priority="-1">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" />
        </xsl:copy>
    </xsl:template>
    
    <!-- When the  target location does not exist, generate one -->
    <xsl:template match="sfd:deployment[not(exists(sfd:targetLocation))]" priority="1">
      <xsl:copy>
        <xsl:copy-of select="@*"/>
         <targetLocation xmlns="http://schemas.active-endpoints.com/appmodules/screenflow/2010/10/avosScreenflow.xsd">
            <xsl:value-of select="$targetLocation"/>
        </targetLocation>
        <xsl:copy-of select="node()"/>
      </xsl:copy>
    </xsl:template>
    
    <!-- Update tags, with agent info -->
    <xsl:template match="sfd:tags|rep:Tags">
        <xsl:copy>
            <xsl:choose> 
                <xsl:when test="empty(.)"> 
                    <xsl:value-of select="concat('.agent:',$targetLocation)"/>
                </xsl:when>
                <xsl:when test="matches(.,'(,)?\.agent:\w+') and count(tokenize(.,',')) = 1"> 
                    <xsl:value-of select="concat('.agent:',$targetLocation)"/> 
                </xsl:when> 
                <xsl:otherwise> 
                    <xsl:value-of select="string-join((replace(.,'(,)?\.agent:\w+',''),concat('.agent:',$targetLocation)),',')"/> 
                </xsl:otherwise> 
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    
    <!-- Update sfd:targetLocation,if exists -->
    <xsl:template match="sfd:targetLocation" priority="2">
        <xsl:copy>
            <xsl:value-of select="$targetLocation"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>
