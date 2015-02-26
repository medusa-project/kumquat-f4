# Importing from CONTENTdm

## Features

* CONTENTdm collections are imported as Fedora 4 container nodes.
* CONTENTdm items are imported as F4 container nodes within their collection
  node.
* CONTENTdm master bytestreams (files) are imported into a sub-node of their
  item node.
* CONTENTdm compound object pages are imported as item nodes within their
  parent item container node.
* CONTENTdm "URL items" are imported as F4 "binary resources redirecting to
  external content," which work pretty much the same.
* Most descriptive metadata is preserved for items, collections, compound
  objects, and compound object pages.
* Dublin Core metadata is imported into the appropriate namespace:
  `http://purl.org/dc/elements/1.1/` or `http://purl.org/dc/terms/`.
* Local "unmapped" metadata is imported into a local namespace.

The resulting F4 node structure looks like this:

    (parent node)
        (collection 1 node)
            (item 1 node)
                (binary node)
            (item 2 node)
                (binary node)
            (item 3 node)
                (external binary node [for "URL items"])
            (compound object node)
                (page 1 node)
                    (binary node)
                (page 2 node)
                    (binary node)
        (collection 2 node)
            ...

## Notes & caveats

* "Full text" is skipped.
* Custom Dublin Core "field names" will be lost. For example, a field called
  "Costume Name" mapped to the DC "title" element will become simply "Title."
* Unmapped elements will be assigned a name of "unmapped".
* Only one level of compound object structure will be imported.
* CONTENTdm field settings like searchable, hidden, etc. are ignored. (These
  would either work differently or are not applicable to F4.)

## Instructions

1. The CONTENTdm source data should be a folder containing one or more
   CONTENTdm collection folders, alongside XML metadata files exported from the
   CONTENTdm administration module in "CONTENTdm Standard XML format including
   all page-level metadata." Collection folders and XML files should be named
   according to the collection's alias, like this:

        source_folder/
          collection1/    <-- Collection folder
          collection1.xml <-- Collection's exported metadata
          collection2/
          collection2.xml
          catalog.txt     <-- CONTENTdm catalog.txt file

   (The `catalog.txt` file can be found in the CONTENTdm web server's document
   root. To skip certain collections, comment them out with a pound (`#`)
   sign.)

2. Run `bundle exec rake kumquat:cdm_import[/path/to/source/data]`. This task
   will output status information for each item.

   This command will delete old collection node (and all child nodes) before
   adding new ones, thus cleaning up after itself, but the generated "web IDs"
   will be different, thus breaking public URLs. This is, for the time being
   anyway, a one-shot importer.
