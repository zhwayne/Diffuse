# Diffuse

## 简介
一个带有彩色阴影的 View 😀.

demo:

PNG                
![](./demo1.png)

<picture class="picture">
  <source type="image/webp" srcset="demo.webp">
</picture>

## 使用

`Diffuse` 派生自 `UIView`，你可以重新设置其 `contentView` 属性(推荐做法)，或者在其上添加 subview，最后记得调用 `refresh()` 方法刷新阴影。

 > 注意：如果你需要圆角效果，可以对 `contentView` 做相应设置，不要直接修改 Diffuse 及其子类，这样做会引发一些未定义的问题。

