from app import create_app, db
from app.models import User, Employee, Ticket

def init_db():
    app = create_app()
    with app.app_context():
        db.create_all()
        print("Database tables created.")

        # # Optionally, you can add some initial data here
        # if User.query.count() == 0:
        #     admin = User(username='admin', email='admin@example.com', is_admin=True, is_approved=True)
        #     admin.set_password('admin_password')
        #     db.session.add(admin)
        #     db.session.commit()
        #     print("Admin user created.")

if __name__ == '__main__':
    print("Database initialization script loaded. Use init_db() function to initialize the database.")