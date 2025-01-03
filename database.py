import BTrees.Interfaces
import ZODB, ZODB.FileStorage
import Game.Classes
import BTrees

import Game

storage = ZODB.FileStorage.FileStorage('DB/Data/mydata.fs')
db = ZODB.DB(storage)
connection = db.open()
root = connection.root

root.accounts = BTrees.OOBTree.BTree()
root.accounts['account-1'] = Game.Classes.Player()



