namespace UniShare.API.Exceptions;

public abstract class DomainException : Exception
{
    public int StatusCode { get; }

    protected DomainException(string message, int statusCode) : base(message)
    {
        StatusCode = statusCode;
    }
}

public class DuplicateEmailException : DomainException
{
    public DuplicateEmailException(string message) : base(message, 409) { }
}

public class DuplicatePhoneException : DomainException
{
    public DuplicatePhoneException(string message) : base(message, 409) { }
}

public class InvalidCredentialsException : DomainException
{
    public InvalidCredentialsException(string message) : base(message, 401) { }
}

public class AccountInactiveException : DomainException
{
    public AccountInactiveException(string message) : base(message, 403) { }
}

public class InvalidRefreshTokenException : DomainException
{
    public InvalidRefreshTokenException(string message) : base(message, 401) { }
}

public class NotFoundException : DomainException
{
    public NotFoundException(string message) : base(message, 404) { }
}

public class ForbiddenException : DomainException
{
    public ForbiddenException(string message) : base(message, 403) { }
}

public class BusinessRuleViolationException : DomainException
{
    public BusinessRuleViolationException(string message) : base(message, 409) { }
}
