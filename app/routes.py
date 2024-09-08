import os
from flask import Blueprint, render_template, redirect, url_for, flash, request
from flask_login import login_user, login_required, logout_user, current_user
from werkzeug.security import generate_password_hash, check_password_hash
from werkzeug.utils import secure_filename
from app import db
from app.models import User, Employee
from app.forms import LoginForm, RegistrationForm, EmployeeForm
from app.models import Ticket
from app.forms import TicketForm, TicketResponseForm

main = Blueprint('main', __name__)

@main.route('/')
def index():
    return render_template('index.html')

@main.route('/login', methods=['GET', 'POST'])
def login():
    if current_user.is_authenticated:
        return redirect(url_for('main.index'))
    form = LoginForm()
    if form.validate_on_submit():
        user = User.query.filter_by(username=form.username.data).first()
        if user is None or not user.check_password(form.password.data):
            flash('Invalid username or password')
            return redirect(url_for('main.login'))
        if not user.is_approved:
            flash('Your account has not been approved yet. Please wait for admin approval.')
            return redirect(url_for('main.login'))
        login_user(user, remember=form.remember_me.data)
        return redirect(url_for('main.index'))
    return render_template('login.html', title='Sign In', form=form)

@main.route('/logout')
@login_required
def logout():
    logout_user()
    return redirect(url_for('main.index'))

@main.route('/register', methods=['GET', 'POST'])
def register():
    if current_user.is_authenticated:
        return redirect(url_for('main.index'))
    form = RegistrationForm()
    if form.validate_on_submit():
        user = User(username=form.username.data, email=form.email.data)
        user.set_password(form.password.data)
        
        # Make the first user an admin and approve them
        if User.query.count() == 0:
            user.is_admin = True
            user.is_approved = True
        
        db.session.add(user)
        db.session.commit()
        flash('Congratulations, you are now a registered user!')
        return redirect(url_for('main.login'))
    return render_template('register.html', title='Register', form=form)

@main.route('/employee_list')
@login_required
def employee_list():
    employees = Employee.query.all()
    return render_template('employee_list.html', employees=employees)

@main.route('/employee/<int:id>')
@login_required
def employee_profile(id):
    employee = Employee.query.get_or_404(id)
    return render_template('employee_profile.html', employee=employee)

@main.route('/add_employee', methods=['GET', 'POST'])
@login_required
def add_employee():
    form = EmployeeForm()
    if form.validate_on_submit():
        filename = None
        if form.picture.data:
            filename = secure_filename(form.picture.data.filename)
            form.picture.data.save(os.path.join('app', 'static', 'uploads', filename))
        
        employee = Employee(
            full_name=form.full_name.data,
            age=form.age.data,
            phone_number=form.phone_number.data,
            email=form.email.data,
            role=form.role.data,
            picture=filename,
            user_id=current_user.id
        )
        db.session.add(employee)
        db.session.commit()
        flash('Employee added successfully')
        return redirect(url_for('main.employee_list'))
    return render_template('add_employee.html', form=form)

@main.route('/delete_employee/<int:id>', methods=['POST'])
@login_required
def delete_employee(id):
    if not current_user.is_admin:
        flash('You do not have permission to delete employees.')
        return redirect(url_for('main.employee_list'))
    employee = Employee.query.get_or_404(id)
    db.session.delete(employee)
    db.session.commit()
    flash('Employee deleted successfully')
    return redirect(url_for('main.employee_list'))

@main.route('/admin/approve_users')
@login_required
def approve_users():
    if not current_user.is_admin:
        flash('You do not have permission to access this page.')
        return redirect(url_for('main.index'))
    users = User.query.filter_by(is_approved=False).all()
    return render_template('approve_users.html', users=users)

@main.route('/admin/approve_user/<int:user_id>')
@login_required
def approve_user(user_id):
    if not current_user.is_admin:
        flash('You do not have permission to perform this action.')
        return redirect(url_for('main.index'))
    user = User.query.get_or_404(user_id)
    user.is_approved = True
    db.session.commit()
    flash(f'User {user.username} has been approved.')
    return redirect(url_for('main.approve_users'))

@main.route('/benefits')
def benefits():
    return render_template('benefits.html')

@main.route('/create_ticket', methods=['GET', 'POST'])
@login_required
def create_ticket():
    if not hasattr(current_user, 'employee') or not current_user.employee:
        flash('You do not have an associated employee record. Please contact an administrator.', 'warning')
        return redirect(url_for('main.index'))

    form = TicketForm()
    if form.validate_on_submit():
        ticket = Ticket(
            title=form.title.data,
            description=form.description.data,
            ticket_type=form.ticket_type.data,
            employee_id=current_user.employee.id
        )
        db.session.add(ticket)
        db.session.commit()
        flash('Your ticket has been created!', 'success')
        return redirect(url_for('main.view_tickets'))
    return render_template('create_ticket.html', title='Create Ticket', form=form)

@main.route('/view_tickets')
@login_required
def view_tickets():
    if current_user.is_admin:
        # For admins, fetch all tickets with user and employee information
        tickets = db.session.query(
            Ticket,
            Employee.full_name.label('employee_name'),
            User.username.label('username')
        ).join(Employee, Ticket.employee_id == Employee.id)\
         .join(User, Employee.user_id == User.id)\
         .all()
    else:
        # For regular users, fetch only their tickets
        if current_user.employee:
            tickets = Ticket.query.filter_by(employee_id=current_user.employee.id).all()
        else:
            flash('You do not have an associated employee record. Please contact an administrator.', 'warning')
            tickets = []
    
    return render_template('view_tickets.html', title='View Tickets', tickets=tickets, is_admin=current_user.is_admin)

@main.route('/ticket/<int:ticket_id>', methods=['GET', 'POST'])
@login_required
def ticket_detail(ticket_id):
    ticket = Ticket.query.get_or_404(ticket_id)
    form = TicketResponseForm()
    
    if current_user.is_admin and form.validate_on_submit():
        ticket.admin_response = form.admin_response.data
        ticket.status = form.status.data
        ticket.is_approved = None if form.is_approved.data == 'None' else (form.is_approved.data == 'True')
        db.session.commit()
        flash('Your response has been submitted.', 'success')
        return redirect(url_for('main.view_tickets'))
    
    return render_template('ticket_detail.html', title='Ticket Detail', ticket=ticket, form=form)