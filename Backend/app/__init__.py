from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_jwt_extended import JWTManager
from flask_migrate import Migrate
from flask_marshmallow import Marshmallow
from flasgger import Swagger
from .config import config_by_name

# Initialize extensions
db = SQLAlchemy()
jwt = JWTManager()
ma = Marshmallow()
migrate = Migrate()
swagger = Swagger()

def create_app(config_name='default'):
    """
    Application factory function.
    
    :param config_name: The name of the configuration to use (e.g., 'development', 'production').
    :return: The configured Flask application instance.
    """
    app = Flask(__name__)
    
    # Load the configuration
    app.config.from_object(config_by_name[config_name])
    
    # Initialize extensions
    db.init_app(app)
    jwt.init_app(app)
    ma.init_app(app)
    migrate.init_app(app, db)
    swagger.init_app(app)
    
    # Register blueprints here
    from .main import main_bp
    app.register_blueprint(main_bp)

    from .auth import auth_bp
    app.register_blueprint(auth_bp)

    from .parking import parking_bp
    app.register_blueprint(parking_bp)

    from .api_v1 import api_v1_bp
    app.register_blueprint(api_v1_bp)
    
    return app 