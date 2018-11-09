{% if not is_home() and toc(page.content) and theme.toc and page.toc %}
  <div class="post-toc" id="post-toc">
    <h2 class="post-toc-title">文章目录</h2>
    <div class="post-toc-content">
      {{ toc(page.content, {list_number: false}) }}
    </div>
  </div>
{% endif %}