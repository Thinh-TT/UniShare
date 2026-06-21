namespace UniShare.API.Models;

public class ApiResponse<T>
{
    public T? Data { get; set; }
    public string Message { get; set; } = "Success";

    public ApiResponse() { }

    public ApiResponse(T data, string message = "Success")
    {
        Data = data;
        Message = message;
    }
}

public static class ApiResponse
{
    public static ApiResponse<T> Success<T>(T data, string message = "Success")
        => new(data, message);
}
