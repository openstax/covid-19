<xsl:transform
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:fn="http://www.w3.org/2005/xpath-functions"
  xmlns:j="http://www.w3.org/2005/xpath-functions"
  xmlns:h="http://www.w3.org/1999/xhtml"
  xmlns:m="http://www.w3.org/1998/Math/MathML"
  xmlns:func="https://philschatz.com/xslt-functions"
  xmlns:p="https://philschatz.com/temporary-namespace"
  expand-text="yes"
  version="3.0">
  
  <xsl:output method="xhtml" html-version="5"/>

  <xsl:include href="mml2tex/mmltex.xsl"/>


  <xsl:param name="bookName" as="xs:string"/>
  <xsl:param name="metadataPath" as="xs:string"/>
  <xsl:param name="metadata" select="document($metadataPath)"/>

  <xsl:key name="identified-element" match="*[@id]" use="@id"/>

  <xsl:template name="setAgeSubjectAlignment">
    <xsl:variable name="subject">
      <xsl:choose>
        <xsl:when test="$bookName = 'microbiology'">Biology</xsl:when>
        <xsl:when test="$bookName = 'accounting-vol-1'">Business</xsl:when>
        <xsl:when test="$bookName = 'accounting-vol-2'">Business</xsl:when>
        <xsl:when test="$bookName = 'business-ethics'">Business</xsl:when>
        <xsl:when test="$bookName = 'history'">History</xsl:when>
        <xsl:otherwise>
          <xsl:message terminate="yes">Unsupported book "{$bookName}". Update this XSLT file</xsl:message>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <div>
      <span itemprop="educationalAlignment" itemscope="itemscope" itemtype="http://schema.org/AlignmentObject">
        <strong> Subject: </strong>
        <meta itemprop="alignmentType" content="educationalSubject"/>
        <span itemprop="targetName">{$subject}</span>
      </span>
      <span itemprop="educationalAlignment" itemscope="itemscope" itemtype="http://schema.org/AlignmentObject">
        <strong> Grade: </strong>
        <meta itemprop="alignmentType" content="educationalLevel"/>
        <span itemprop="targetName">10th Grade</span>
      </span>
      <strong> Age: </strong>
      <span itemprop="typicalAgeRange">16+</span>
      <meta itemprop="educationalUse" content="practice"/>
    </div>
  </xsl:template>

  <xsl:template match="/">
    <xsl:variable name="json">
      <xsl:apply-templates select="@*|node()"/>
    </xsl:variable>
    
    <xsl:if test="$json//p:exercise">
      <h:html>
        <h:head>
          <h:title>Practice Exercises for {$bookName}</h:title>
        </h:head>
        <h:body>
          <xsl:apply-templates mode="toWebpage" select="$json"/>
        </h:body>
      </h:html>
    </xsl:if>
  </xsl:template>


  <xsl:template mode="toWebpage" match="p:chapter[p:exercise]">

    <!-- Format of the ToC looks like this:

    <map>
        <string key="id">f88a83cd-2dd3-50d4-8027-c3db3d5ad0ab@10.1</string>
        <string key="title">&lt;span class="os-text"&gt;Short Answer&lt;/span&gt;</string>
        <string key="slug"
    </map>

    -->
    <xsl:variable name="introUuid" select="@intro-uuid" as="xs:string"/>
    <xsl:variable name="tocNode" select="$metadata//fn:map[fn:string[@key='slug']][starts-with(fn:string[@key='id']/text(), $introUuid)]"/>
    <xsl:variable name="slug" select="$tocNode/fn:string[@key='slug']/text()" as="xs:string"/>


    <div itemscope="itemscope" itemtype="http://schema.org/Quiz">
      <h2>
        <span class="chapter-number">{@number}: </span>
        <a itemprop="url" href="https://openstax.org/books/{$bookName}/pages/{$slug}?from=google-practice">
          <span itemprop="about">{@title}</span>
        </a>
      </h2>

      <xsl:call-template name="setAgeSubjectAlignment"/>

      <xsl:apply-templates mode="toWebpage" select="node()">
        <xsl:with-param name="idPrefix">id-ch{@number}</xsl:with-param>
      </xsl:apply-templates>
    </div>
  </xsl:template>

  <xsl:template mode="toWebpage" match="p:exercise">
    <xsl:param name="idPrefix" as="xs:string"/>
    <xsl:variable name="number" select="@number"/>
    <xsl:variable name="letter" select="p:answer/text()"/>
    <xsl:variable name="acceptedAnswerPosition">
      <xsl:choose>
        <xsl:when test="$letter = 'A'">1</xsl:when>
        <xsl:when test="$letter = 'B'">2</xsl:when>
        <xsl:when test="$letter = 'C'">3</xsl:when>
        <xsl:when test="$letter = 'D'">4</xsl:when>
        <xsl:when test="$letter = 'E'">5</xsl:when>
        <xsl:otherwise>
          <xsl:message terminate="yes">Invalid answer option "{$letter}" . Expected A-E</xsl:message>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <div itemprop="hasPart" itemscope="itemscope" itemtype="http://schema.org/PracticeProblem">
      <meta itemprop="practiceProblemType" content="MultipleChoicePracticeProblem"/>

      <xsl:call-template name="setAgeSubjectAlignment"/>

      <div itemprop="hasPart" itemscope="itemscope" itemtype="http://schema.org/Question">
        <meta itemprop="encodingFormat" content="text/html"/>
        <div itemprop="name">Choose the best answer</div>
        <div itemprop="text">
          <xsl:apply-templates mode="toWebpage" select="p:stem/node()"/>
        </div>
        <meta itemprop="acceptedAnswer" content="{$idPrefix}-{$number}-{$acceptedAnswerPosition}"/>
        <xsl:comment><span>Accepted Answer: {$letter}</span></xsl:comment>

        <ol type="A">
          <xsl:for-each select="p:option">
            <li id="{$idPrefix}-{$number}-{position()}" itemprop="suggestedAnswer" itemscope="itemscope" itemtype="http://schema.org/Answer">
              <meta itemprop="encodingFormat" content="text/html"/>
              <div itemprop="text">
                <xsl:apply-templates mode="toWebpage" select="@*|node()"/>
              </div>
            </li>
          </xsl:for-each>
        </ol>
      </div>
    </div>

  </xsl:template>

  <xsl:template mode="toWebpage" match="p:*|p:*/@*">
    <xsl:copy>
      <xsl:apply-templates mode="toWebpage" select="@*|node()"/>
    </xsl:copy>
  </xsl:template>



  <xsl:template match="*[@data-type='chapter']">
    <xsl:variable name="chapterNumber" select="h:h1[@data-type='document-title']/*[@class='os-number'][1]/text()" />
    <xsl:variable name="chapterTitle">
      <xsl:value-of select="*[@data-type='metadata']/*[@data-type='document-title']/node()"/>
    </xsl:variable>
    <p:chapter number="{$chapterNumber}" title="{$chapterTitle}" intro-uuid="{*[@data-type='page'][1]/@id}">
      <xsl:apply-templates select="node()">
        <xsl:with-param tunnel="yes" name="chapterNumber" select="$chapterNumber"/>
      </xsl:apply-templates>
    </p:chapter>
  </xsl:template>

  <xsl:template match="*[@data-uuid-key]">
    <xsl:variable name="title" select="*[@data-type='document-title']//text()"/>
    <xsl:if test=".//*[@data-type='exercise']">
      <xsl:apply-templates select="node()">
        <xsl:with-param tunnel="yes" name="dataUuidKey" select="@data-uuid-key"/>
      </xsl:apply-templates>
    </xsl:if>
  </xsl:template>

  <xsl:template match="*[@data-type='composite-page']//*[@data-type='exercise']">
    <xsl:param tunnel="yes" name="dataUuidKey"/>
    <xsl:variable name="exerciseNumber" select="*[@data-type='problem']/*[@class='os-number']/text()"/>
    <xsl:variable name="answerHref" select="*[@data-type='problem']/h:a[@class='os-number']/@href"/>
    <xsl:variable name="problem" select="*[@data-type='problem']/*[func:hasClass(@class, 'os-problem-container')]"/>
    <xsl:variable name="options" select="$problem/h:ol[@type='a' or @type='A']"/>
    <xsl:variable name="stemRoot" select="$problem/node()[not(self::h:ol[@type='a' or @type='A'])]"/>

    <!-- <xsl:variable name="stem" select="$problem/*[1]"/> -->
    <xsl:variable name="stemText">
      <xsl:apply-templates mode="stringify" select="$stemRoot"><xsl:with-param tunnel="yes" name="exerciseNumber" select="$exerciseNumber"/></xsl:apply-templates>
    </xsl:variable>

    <xsl:variable name="answerElement" select="key('identified-element', substring-after($answerHref, '#'))"/>
    <xsl:variable name="answer">
      <xsl:apply-templates mode="stringifyOld" select="$answerElement/*[func:hasClass(@class,'os-solution-container')]/node()"><xsl:with-param tunnel="yes" name="exerciseNumber" select="$exerciseNumber"/></xsl:apply-templates>
    </xsl:variable>

    <!-- Only output multiple choice answers -->
    <xsl:variable name="answerChar" select="normalize-space($answer)"/>
    <xsl:if test="string-length($answerChar) = 1 and ( $answerChar = 'A' or $answerChar = 'B' or $answerChar = 'C' or $answerChar = 'D' or $answerChar = 'E' )">

      <p:exercise number="{$exerciseNumber}">
        <p:stem>{$stemText}</p:stem>

        <!-- Decide whether to convert the options or skip them -->
        <xsl:if test="$options">
          <xsl:for-each select="$options/h:li">
            <xsl:variable name="option">
              <xsl:apply-templates mode="stringify" select="node()"><xsl:with-param tunnel="yes" name="exerciseNumber" select="$exerciseNumber"/></xsl:apply-templates>
            </xsl:variable>
            <xsl:variable name="optionImages" select=".//h:img/@src"/>

            <p:option>{$option}</p:option>
          </xsl:for-each>
        </xsl:if>

        <p:answer>{normalize-space($answer)}</p:answer>
      </p:exercise>
    </xsl:if>
  </xsl:template>


  <xsl:template name="stringifyOrReportWhyNotJson">
    <xsl:param name="key"/>
    <xsl:param name="context"/>
    <xsl:param name="chapterNumber" tunnel="yes"/>
    <xsl:param name="dataUuidKey" tunnel="yes"/>
    <xsl:param name="exerciseNumber"/>

    <j:string>
      <!-- <xsl:choose>
        <xsl:when test="$context[not(*)]"> -->
          <xsl:attribute name="key">
            <xsl:value-of select="$key"/>
          </xsl:attribute>
          <xsl:sequence select="$context"/>
          <xsl:message>"{$bookName}", "{$dataUuidKey}", {$chapterNumber},{$exerciseNumber}, "converted_{$key}"</xsl:message>
        <!-- </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="key">
            <xsl:text>unconverted_</xsl:text>
            <xsl:value-of select="$key"/>
          </xsl:attribute>
          <xsl:message>"{$bookName}", "{$dataUuidKey}", {$chapterNumber},{$exerciseNumber}, "FIX:UNCONVERTED_{$key}", "{$context/*[1]/local-name()}"</xsl:message>
          <xsl:text>Unconverted element: </xsl:text>
          <xsl:value-of select="$context/*[1]/local-name()"/>
        </xsl:otherwise>
      </xsl:choose> -->
    </j:string>
  </xsl:template>

  <xsl:template name="stringifyOrReportWhyNotRaw">
    <xsl:param name="context"/>
    <xsl:param name="chapterNumber" tunnel="yes"/>
    <xsl:param name="dataUuidKey" tunnel="yes"/>
    <xsl:param name="exerciseNumber"/>

    <!-- <xsl:choose>
      <xsl:when test="$context[not(*)]"> -->
        <xsl:message>"{$bookName}", "{$dataUuidKey}", {$chapterNumber},{$exerciseNumber}, "ANSWER", "{normalize-space($context)}"</xsl:message>
      <!-- </xsl:when>
      <xsl:otherwise>
        <xsl:message>"{$bookName}", "{$dataUuidKey}", {$chapterNumber},{$exerciseNumber}, "FIX:UNCONVERTED_ANSWER", "{$context/*[1]/local-name()}"</xsl:message>
      </xsl:otherwise>
    </xsl:choose> -->
  </xsl:template>

  <xsl:template name="constructImage">
    <xsl:param name="key"/>
    <xsl:param name="hrefs"/>
    <xsl:param name="chapterNumber" tunnel="yes"/>
    <xsl:param name="dataUuidKey" tunnel="yes"/>
    <xsl:param name="exerciseNumber"/>

    <xsl:if test="count($hrefs) > 1">
      <xsl:message>"{$bookName}", "{$dataUuidKey}", {$chapterNumber},{$exerciseNumber}, "FIX:MULTIPLE_IMAGES", {count($hrefs)}</xsl:message>
    </xsl:if>

    <xsl:if test="$hrefs">
      <j:array>
        <xsl:attribute name="key">
          <xsl:value-of select="$key"/>
          <xsl:text>_images</xsl:text>
        </xsl:attribute>
        <xsl:for-each select="$hrefs">
          <xsl:variable name="href" select="."/>
          <j:string>
            <xsl:choose>
              <xsl:when test="starts-with($href, 'http')">
                <xsl:value-of select="normalize-space($href)"/>
              </xsl:when>
              <xsl:when test="starts-with($href, 'm')">
                <xsl:variable name="module" select="substring-before($href, '/')"/>
                <xsl:variable name="filename" select="substring-after($href, '/')"/>
                <xsl:text>https://legacy.cnx.org/content/</xsl:text>
                <xsl:value-of select="$module"/>
                <xsl:text>/latest/</xsl:text>
                <xsl:value-of select="$filename"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:message>"{$bookName}", "{$dataUuidKey}", {$chapterNumber},{$exerciseNumber}, "FIX:BAD_IMAGE_LINK", {$href}</xsl:message>
                <xsl:text>[Unknown image ref: "</xsl:text>
                <xsl:value-of select="$href"/>
                <xsl:text>"]</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </j:string>
        </xsl:for-each>
      </j:array>
    </xsl:if>
  </xsl:template>

  <!-- Valid values are:
    - "p" free response (paragraph)
    - "m" multiple choice
    - "x" checkbox
    - "b" true/false 
    -->
  <xsl:template name="defaultType">
    <xsl:param name="dataUuidKey" tunnel="yes"/>
    <xsl:variable name="combined">{$bookName}|{$dataUuidKey}</xsl:variable>
    <xsl:choose>

      <xsl:when test="$combined='apbiology|.science-practice'">p</xsl:when>
      <xsl:when test="$combined='apbiology|.review'">m</xsl:when>
      <xsl:when test="$combined='apbiology|.critical-thinking'">m</xsl:when>
      <xsl:when test="$combined='apbiology|.ap-test-prep'">m</xsl:when>

      <xsl:when test="$combined='macroeconap-2e|.self-check-questions'">m</xsl:when>
      <xsl:when test="$combined='macroeconap-2e|.review-questions'">p</xsl:when>
      <xsl:when test="$combined='macroeconap-2e|.critical-thinking'">p</xsl:when>
      <xsl:when test="$combined='macroeconap-2e|.problems'">m</xsl:when>

      <xsl:when test="$combined='microeconap-2e|.self-check-questions'">m</xsl:when>
      <xsl:when test="$combined='microeconap-2e|.review-questions'">p</xsl:when>
      <xsl:when test="$combined='microeconap-2e|.critical-thinking'">p</xsl:when>
      <xsl:when test="$combined='microeconap-2e|.problems'">m</xsl:when>

      <xsl:when test="$combined='chemistry-2e|.exercises'">m</xsl:when>

      <xsl:when test="$combined='psychology-2e|.review-questions'">m</xsl:when>
      <xsl:when test="$combined='psychology-2e|.critical-thinking'">p</xsl:when>
      <xsl:when test="$combined='psychology-2e|.personal-application'">p</xsl:when>

      <xsl:when test="$combined='apphysics|.conceptual-questions'">p</xsl:when>
      <xsl:when test="$combined='apphysics|.problems-exercises'">p</xsl:when>
      <xsl:when test="$combined='apphysics|.ap-test-prep'">m</xsl:when>

      <xsl:when test="$combined='hs-statistics|.practice'">p</xsl:when>
      <xsl:when test="$combined='hs-statistics|.bring-together-exercises'">p</xsl:when>
      <xsl:when test="$combined='hs-statistics|.free-response'">m</xsl:when>
      <xsl:when test="$combined='hs-statistics|.bring-together-homework'">p</xsl:when>

      <xsl:when test="$combined='physics|.conceptual-questions'">p</xsl:when>
      <xsl:when test="$combined='physics|.problems-exercises'">p</xsl:when>

      <xsl:otherwise>
        <xsl:message terminate="yes">UNMATCHED_CATEGORY {$combined}</xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

<xsl:template mode="stringifyOld" match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template mode="stringifyOld" match="h:em">
    <xsl:apply-templates mode="stringifyOld" select="node()"/>
  </xsl:template>

  <xsl:template mode="stringifyOld" match="h:strong">
    <xsl:apply-templates mode="stringifyOld" select="node()"/>
  </xsl:template>

  <xsl:template mode="stringifyOld" match="h:a[starts-with(@href, 'http')]">
    <xsl:text> </xsl:text>
    <xsl:value-of select="@href"/>
    <xsl:text> </xsl:text>
  </xsl:template>

  <xsl:template mode="stringifyOld" match="h:a[starts-with(@href, '#')][not(starts-with(text(), 'LO '))]">
    <xsl:text>[</xsl:text>
    <xsl:apply-templates mode="stringifyOld" select="node()"/>
    <xsl:text>]</xsl:text>
  </xsl:template>

  <!-- Discard the LO link at the beginning of every exercise in accounting -->
  <xsl:template mode="stringifyOld" match="h:a[starts-with(@href, '#')][starts-with(text(), 'LO ')]"/>

  <xsl:template mode="stringifyOld" match="h:sub">
    <xsl:text>_</xsl:text>
    <xsl:apply-templates mode="stringifyOld" select="node()"/>
  </xsl:template>

  <xsl:template mode="stringifyOld" match="h:sup">
    <xsl:text>^</xsl:text>
    <xsl:apply-templates mode="stringifyOld" select="node()"/>
  </xsl:template>

  <xsl:template mode="stringifyOld" match="h:span|h:div|h:p|h:br">
    <xsl:apply-templates mode="stringifyOld" select="node()"/>
  </xsl:template>

  <xsl:template mode="stringifyOld" match="h:span[@data-math]">
    <xsl:param required="yes" name="dataUuidKey" tunnel="yes"/>
    <xsl:param required="yes" name="chapterNumber" tunnel="yes"/>
    <xsl:param required="yes" name="exerciseNumber" tunnel="yes"/>
    <xsl:variable name="val" select="@data-math"/>
    <xsl:message>"{$bookName}", "{$dataUuidKey}", {$chapterNumber},{$exerciseNumber}, "FIX:TEX_MATH", "{$val}"</xsl:message>
    <xsl:apply-templates mode="stringifyOld" select="node()"/>
  </xsl:template>

  <!-- Discard figures and images because we extracted their URL out already -->
  <xsl:template mode="stringifyOld" match="h:figure|h:img"/>

  <!-- Discard titles -->
  <xsl:template mode="stringifyOld" match="h:span[@data-type='title']"/>

  <!-- **************** 
       * Math 
       **************** -->

  <xsl:template mode="stringifyOld" match="m:*|m:*/@*">
    [itsmathbutwedontcareforthispurpose]
  </xsl:template>


  <xsl:template mode="stringify" match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates mode="stringify" select="@*"/>
      <xsl:apply-templates mode="stringify" select="node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template mode="stringify" match="m:*|m:*/@*">
    $$<xsl:apply-templates mode="mml2tex" select="."/>$$
  </xsl:template>

  <!--Change image URLs so they are absolute-->
  <xsl:template mode="stringify" match="h:img/@src">
    <xsl:variable name="href" select="."/>
    <xsl:variable name="url">
      <xsl:choose>
        <xsl:when test="starts-with($href, 'http')">
          <xsl:value-of select="normalize-space($href)"/>
        </xsl:when>
        <xsl:when test="starts-with($href, 'm')">
          <xsl:variable name="module" select="substring-before($href, '/')"/>
          <xsl:variable name="filename" select="substring-after($href, '/')"/>
          <xsl:text>https://legacy.cnx.org/content/</xsl:text>
          <xsl:value-of select="$module"/>
          <xsl:text>/latest/</xsl:text>
          <xsl:value-of select="$filename"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message terminate="no">Unknown image ref={.}</xsl:message>
          <!-- <xsl:message>"{$bookName}", "{$dataUuidKey}", {$chapterNumber},{$exerciseNumber}, "FIX:BAD_IMAGE_LINK", {$href}</xsl:message>
          <xsl:text>[Unknown image ref: "</xsl:text>
          <xsl:value-of select="$href"/>
          <xsl:text>"]</xsl:text> -->
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:attribute name="src" select="$url"/>
  </xsl:template>

  <xsl:template match="node()">
    <xsl:apply-templates select="node()"/>
  </xsl:template>

  <xsl:function name="func:hasClass" as="xs:boolean">
      <xsl:param name="class" as="xs:string?"/>
      <xsl:param name="className" as="xs:string"/>
      <xsl:choose>
          <xsl:when test="empty($class)">{true()}</xsl:when>
          <xsl:otherwise>
              <xsl:sequence select="fn:exists(fn:index-of(fn:tokenize($class, '\s+'), $className))"/>
          </xsl:otherwise>
      </xsl:choose>
  </xsl:function>

</xsl:transform>	
