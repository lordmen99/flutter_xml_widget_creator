# flutter widget converter from xml

## Summary

Create a building Widget function from XML, similar to Android Layout XML.

> Notice: This project is experimental.<br>
> Especially, error checking is not enough when xml parsing.<br>
> and it's hard to understand what parsing-error is.

This tool doesn't inflate xml dynamically, only converts xml to dart.  
And the created-code is similar to `Stateless Function Component` (in React).


```xml
<?xml version="1.0" encoding="utf-8"?>
<layout>
  <data>
    <import package="package:flutter/material.dart"/>
    <stream name="count" type="int" initialData="0" />
    <var name="sink" type="Sink<int>" />
  </data>

  <RaisedButton
      onPress="() {sink.add($count + 1);}"/>
      <Text
          _text="$count.toString()"/>
  </RaisedButton>
</layout>
```

following dart file will be created

```dart
Widget buildCounterWidget({
    Key key,
    @required Stream<int> count,
    @required Sink<int> sink}) {
  return Container(
    child: StreamBuilder<int>(
        stream: count,
        builder: (ctx, countSnapShot) {
          return RaisedButton(
            onPress: () { sink.add(countSnapShot.data + 1); }
            child: Text(countSnapShot.data.toString()),
          );
        }),
  );
}
```

## Motivation

* It's difficult to recognize *close-position* in dart code (for me). 
  * XML-format is more easier to do this.
  * And I'm familier with writing layout in XML, so I want to use XML.
* Reducing template code when using 'StreamBuilder'
  * To update widgets, we need to wrap each widget with StreamBuilder.
  * It makes deep-indent and many same code-blocks.
  * This tool makes `StreamBulider` automatically.
* Wrapping widgets with layout-widget, such as `Padding` or `Expanded`, is boring.
  * And it makes deep indents and makes code unreadable.
  * so I want to add some syntax-suger.

## How to use

* Install dart-sdk(2.2) and flutter-sdk(1.2).
* download whole this project.
  * I'm not planning to publish this in Dart-Pub, because this is very EXPERIMENTAL.
* In root dir, run `pub run xml_widget_creator [XmlFile or Directory path]`
* A dart file will be created in the same directory as the xml file.

## Run examples

* In project root dir, run `pub run xml_widget_creator ./example/[dir]/lib/`.
* In each example dir, run `flutter run` for executing flutter app.
* To run test, run `pub run test test/` in root dir.

<hr>

## XML Rules

Similar to Android-DataBinding-XML.

* `<layout>` :  root element
* `<data>` : declare using package, streams and other variables
  * `<import pakage=PKGNAME />` : import packages
  * If no import tags, add material package as default.
  * `<stream name=NAME type=TYPE initialData=DATA />` : declare a stream used in widgets
  * `<var name=NAME type=TYPE />` : declare other variables(callback, constant-value, etc...)
* widget tree(only one widget)

In Widget tree, 

* `tag-name` converted to Class-Name (must start with Upper-case)
* each `attribute-name` converted to constructor-parameter.
* each `attribute-value` converted as raw dart code.
  * So if you want to use string-literal, you need to wrap it with single-qoute.
  * ex: *_text="'STRING_LITERAL'"*

## Special Rules in widget tree

 * tag-name that starts with lower-case will converted as parent attribute.
   * Using in widget-attribute, such as *Scaffold.appBar*
* `multi_child` attribute
  * takes boolean value, whethere child-tree is `child` or `children`
  * if true, the children-trees are declared as *children: []*
  * if false, the child-tree is declared as *child:*
  * In xml, it is unable to understand whether child-tree is *children* or *child*.
  * In some default widget, this tool uses `children` as default. such as `Row` or `Column`.
* `$` syntax
  * when you want to use stream value, add `$` before each stream-name.
  * In dart-code, this $-stream will be converted as *SnapShot* value, and wrapped with `StreamBuilder`
* `_` (underscore) attribute
  * if attribute-name starts with `_` , the constructor-key-name will be removed.
  * Usecase: In `Text` Widget, its text-parameter doesn't has key-name, so use `_` attribue.

<hr>

example

```xml
<layout>
  <data>
    <import package="package:flutter/material.dart"/>
    <stream name="count" type="int" initialData="0" />
  </data>

  <Scaffold>
    <appBar> <!-- this will be converted as Scaffold's parameter -->
      <AppBar>
        <!-- text doesn't need key in constructor, so add "_" -->
        <title><Text _text="'Title'"/></title>
      </AppBar>
    </appBar>
    <body>
      <!-- add $ before streams to use snapshot value. -->
      <Text _text="$count.toString()"/>
    </body>
  </Scaffold>
</layout>
```

## Shorthanded attributes

To reduce widget-nesting, this tool supports some special attributes.

* `padding` : wrap widget with `Padding`
  * supports css pattern, differ from Flutter-UI.
  * padding="1"  : allEdges
  * padding="1 2" : vertical, horizontal
  * padding="1 2 3" : top, horizontal, bottom
  * padding="1 2 3 4" : top, right, bottom, left
  * takes double value
* `flex` : wrap widget with `Expanded`
  * takes integer value

example

```xml
<Column>
  <Text padding="4" />
  <Text flex="1"/>
</Column>
```

```dart
Widget build() {
  return Column(
    children: [
      Padding(
        padding: EdgeInsets.fromLTRB(4.0, 4.0, 4.0, 4.0),
        child: Text(),
      ),
      Expanded(
        flex: 1,
        child: Text(),
      )
    ]
  );
}
```









