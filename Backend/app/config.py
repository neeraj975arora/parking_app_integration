import os
import logging
from dotenv import load_dotenv

# Load environment variables from a .env file
load_dotenv()

def setup_logging():
    """
    Setup centralized logging configuration for the application.
    Configures global logging level to DEBUG and enables SQL query traces.
    """
    # Configure global logging with detailed format
    logging.basicConfig(
        level=logging.DEBUG,
        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
        datefmt='%Y-%m-%d %H:%M:%S'
    )
    
    # Configure SQLAlchemy engine logger to INFO level for SQL query traces
    sqlalchemy_logger = logging.getLogger('sqlalchemy.engine')
    sqlalchemy_logger.setLevel(logging.INFO)
    
    # Get the main application logger
    logger = logging.getLogger(__name__)
    logger.info("Logging configuration initialized successfully")

class Config:
    """Base configuration."""
    SECRET_KEY = os.environ.get('SECRET_KEY') or 'a-hard-to-guess-string'
    
    # Database configuration
    POSTGRES_USER = os.environ.get('POSTGRES_USER')
    POSTGRES_PASSWORD = os.environ.get('POSTGRES_PASSWORD')
    POSTGRES_DB = os.environ.get('POSTGRES_DB')
    DB_HOST = os.environ.get('DB_HOST', 'db')  # Default to 'db' for Docker service name
    DB_PORT = os.environ.get('DB_PORT', '5432')
    
    SQLALCHEMY_DATABASE_URI = f"postgresql://{POSTGRES_USER}:{POSTGRES_PASSWORD}@{DB_HOST}:{DB_PORT}/{POSTGRES_DB}"
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    RPI_API_KEY = os.environ.get('RPI_API_KEY') or 'super-secret-rpi-key'
    
    # JWT Configuration - Use JWT_SECRET_KEY if available, fallback to SECRET_KEY
    JWT_SECRET_KEY = os.environ.get('JWT_SECRET_KEY') or os.environ.get('SECRET_KEY') or 'jwt-secret-string'
    
    # JWT Settings
    JWT_ACCESS_TOKEN_EXPIRES = 12  # hours
    JWT_ALGORITHM = 'HS256'

    @staticmethod
    def init_app(app):
        pass

class DevelopmentConfig(Config):
    """Development configuration."""
    DEBUG = True
    SQLALCHEMY_ECHO = True

class ProductionConfig(Config):
    """Production configuration."""
    DEBUG = False
    SQLALCHEMY_ECHO = False

class TestingConfig(Config):
    TESTING = True
    SQLALCHEMY_DATABASE_URI = 'sqlite:///:memory:'  # Use in-memory SQLite for tests
    WTF_CSRF_ENABLED = False

# Dictionary to access config classes by name
config_by_name = {
    'development': DevelopmentConfig,
    'production': ProductionConfig,
    'testing': TestingConfig,
    'default': DevelopmentConfig
} 