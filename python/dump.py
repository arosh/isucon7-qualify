import os
import MySQLdb.cursors

config = {
    'db_host': os.environ.get('ISUBATA_DB_HOST', 'localhost'),
    'db_port': int(os.environ.get('ISUBATA_DB_PORT', '3306')),
    'db_user': os.environ.get('ISUBATA_DB_USER', 'root'),
    'db_password': os.environ.get('ISUBATA_DB_PASSWORD', ''),
}

def dbh():
    conn = MySQLdb.connect(
        host   = config['db_host'],
        port   = config['db_port'],
        user   = config['db_user'],
        passwd = config['db_password'],
        db     = 'isubata',
        charset= 'utf8mb4',
        cursorclass= MySQLdb.cursors.DictCursor,
        autocommit = True,
    )
    cur = conn.cursor()
    cur.execute("SET SESSION sql_mode='TRADITIONAL,NO_AUTO_VALUE_ON_ZERO,ONLY_FULL_GROUP_BY'")
    return conn

def main():
    conn = dbh()
    cursor = conn.cursor()
    cursor.execute('SELECT id FROM image')
    ids = [datum['id'] for datum in cursor.fetchall()]
    DIR = '../public/icons'
    if not os.path.isdir(DIR):
        os.mkdir(DIR)
    for id in ids:
        print('id = %d' % id)
        cursor = conn.cursor()
        cursor.execute('SELECT * FROM image WHERE id = %s', (id, ))
        image = cursor.fetchone()
        filename = '%s/%s' % (DIR, image['name'])
        with open(filename, 'wb') as f:
            f.write(image['data'])

if __name__ == '__main__':
    main()
