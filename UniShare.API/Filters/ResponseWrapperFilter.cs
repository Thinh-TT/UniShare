using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using UniShare.API.Models;

namespace UniShare.API.Filters;

public class ResponseWrapperFilter : IAsyncResultFilter
{
    public async Task OnResultExecutionAsync(ResultExecutingContext context, ResultExecutionDelegate next)
    {
        if (context.Result is ObjectResult objectResult)
        {
            // Don't wrap ProblemDetails, file results, or already wrapped responses
            if (objectResult.Value is ProblemDetails ||
                objectResult.Value is ApiResponse<object> ||
                objectResult.Value is PagedResponse<object>)
            {
                await next();
                return;
            }

            var statusCode = objectResult.StatusCode ?? 200;

            if (statusCode is 200 or 201)
            {
                var message = statusCode == 201 ? "Created successfully" : "Success";
                // Use reflection-free wrapping via typed ApiResponse.Success
                var value = objectResult.Value;
                var responseType = typeof(ApiResponse<>).MakeGenericType(value?.GetType() ?? typeof(object));
                var dataProperty = responseType.GetProperty(nameof(ApiResponse<object>.Data))!;
                var messageProperty = responseType.GetProperty(nameof(ApiResponse<object>.Message))!;
                var instance = Activator.CreateInstance(responseType)!;
                dataProperty.SetValue(instance, value);
                messageProperty.SetValue(instance, message);
                objectResult.Value = instance;
            }
            // 204 No Content, errors, etc. — pass through unchanged
        }

        await next();
    }
}
