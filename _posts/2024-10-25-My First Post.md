---
title: My First Post
date: 2024-10-25 14:30:45 -0700
categories: [Programming]
tags: [introduction]     # TAG names should always be lowercase
description: Generating my first post. Start of a new blog 😊
image:
  path: /assets/img/github_icon.png
  width: 1000
  height: 400
  alt: image description can go here.
---

## Here is some code

```cpp
#include <iostream>

int main()
{
    std::cout << "hello world!\n" << std::endl;
    return 0;
}
```
Naming and Path
Create a new file named YYYY-MM-DD-TITLE.EXTENSION and put it in the _posts of the root directory. Please note that the EXTENSION must be one of md and markdown. If you want to save time of creating files, please consider using the plugin Jekyll-Compose to accomplish this.

Front Matter
Basically, you need to fill the Front Matter as below at the top of the post:

<br>

<!-- {% include comment.html %} -->
<!-- 
<script src="https://giscus.app/client.js"
        data-repo="eduardor626/eduardor626.github.io"
        data-repo-id="R_kgDONMh9Gw"
        data-category="Announcements"
        data-category-id="DIC_kwDONMh9G84CkGq0"
        data-mapping="pathname"
        data-strict="0"
        data-reactions-enabled="1"
        data-emit-metadata="0"
        data-input-position="bottom"
        data-theme="preferred_color_scheme"
        data-lang="en"
        crossorigin="anonymous"
        async>
</script>
-->