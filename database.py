import BTrees.Interfaces
import ZODB, ZODB.FileStorage
import Game.Classes
import BTrees

import Game.Classes.Player

storage = ZODB.FileStorage.FileStorage('mydata.fs')
db = ZODB.DB(storage)
connection = db.open()
root = connection.root

root.accounts = BTrees.OOBTree.BTree





