# Gevel-Extension
### An updated implementation of Gevel module used to analyze GiST/GIN indices. Works for PostgreSQL >=9.6.

This extension was created for PostgreSQL users that don't want to setup environment for building PostgreSQL but still want to use [Gevel contrib module](http://www.sai.msu.su/~megera/wiki/Gevel) to analyze their indices. The difference is that building this extension only requires headers and libraries that are packaged with standard PostgreSQL distribution. The implementation was also updated to work with new PostgreSQL version since the API changed and some functions were no longer available.

## Build Instructions
### Windows - Visual Studio
Repository contains preconfigured Visual Studio solution that can be used to build this extension. Only thing that needs to be configured is `POSTGRE_FOLDER` variable in `PropertySheet.props` file to match your PostgreSQL installation folder. The variable is prefilled as an example. Open solution, change build configuration to **Release** and build the solution. You may also change architecture in configuration manager.

### Linux
Makefile is not yet available as it was not neccessary for me. If you'll create one yourself, it will be highly appreciated if you share it with rest of community via [pull request](https://github.com/BetaRavener/Gevel-Extension/pulls).

## Install Instructions
After building library you need to place files into respective folders inside PostgreSQL folder.
* `gevel_ext.dll` - after building, this file is located in `Release\*Arch*\` folder. Copy it to `POSTGRE_FOLDER\lib\`.
* `gevel_ext.sql` - located in repository root folder. Copy it to `POSTGRE_FOLDER\share\extension\` and rename to `gevel_ext--1.0.sql`.
* `gevel_ext.control` - located in repository root folder. Copy it to `POSTGRE_FOLDER\share\extension\`.

### Windows
On Windows, you may use batch scripts that were created to make it easier to copy necessary files. You can find these in `Utility` folder. First, open and edit `config.cmd` so that it matches your system values. Then you can run `install_gevel_module.cmd` which will copy files to correct folders.

## Usage
### Creating Extension
First, you need to install module into database that contains index you want to analyze. This is different from original module, where functions were available globaly but should not present any issue. Use this command to create extension:
```
DROP EXTENSION IF EXISTS gevel_ext CASCADE;
CREATE EXTENSION gevel_ext;
```

### Getting Index OID
After this you should be able to use functions from the extension. Due to some issues with the new API there is another difference from original module - functions doesn't accept name of the index but its OID. This has advantage that OID identifies index without any ambiguity and doesn't require specifying schemas and such. You can find OID of index for example through `pgadmin` by right clicking desired index and going into properties. However, it has also disadvantage that OID changes everytime index is recreated - which will be probably done if you are analyzing it. In that case, it might be more convenient to get OID with SQL, which can be then used when executing function (substitute for `*index_name*` name of your index):
```
SELECT CAST(c.oid AS INTEGER) FROM pg_class c, pg_index i 
WHERE c.oid = i.indexrelid and c.relname = '*index_name*' LIMIT 1
```
 
### Using module
Having OID of index, you can start using the extension. It supports 3 functions:
 
* **gist_stat** - Prints statistics about the index, such as it's size, number of leaf nodes, etc.
* **gist_tree** - Prints index as tree of internal nodes with number of tuples in each page and other data. The depth of tree can be controlled with second argument.
* **gist_print** - Prints actual tuples that create index. For this to work, objects in index must have textual representation (they have to be printable).
 
For more information, please see [original module webpage](http://www.sai.msu.su/~megera/wiki/Gevel).
 
### Examples
Following examples are for index that has internal storage type of `bytea`. Replace `*OID*` with actual OID or select statement presented above.

**Print index as tree with depth 1, using select to get OID**
```
SELECT gist_tree(
(SELECT CAST(c.oid AS INTEGER) FROM pg_class c, pg_index i 
 WHERE c.oid = i.indexrelid and c.relname = '*index_name*' LIMIT 1)
, 1);
```
 
**Dump index into CSV**
```
-- Dump all nodes to CSV.
-- This contains all nodes, even leaf keys, but excludes root
-- (in fact, there is none.. only root page containing level 1 keys).
COPY (SELECT level, valid, encode(a, 'hex') FROM gist_print(*OID*)
AS t(level int, valid bool, a bytea)) TO 'C:\index.csv' WITH CSV
```
