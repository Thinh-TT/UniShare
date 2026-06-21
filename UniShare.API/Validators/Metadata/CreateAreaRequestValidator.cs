using FluentValidation;
using UniShare.API.Models.DTOs.Metadata;

namespace UniShare.API.Validators.Metadata;

public class CreateAreaRequestValidator : AbstractValidator<CreateAreaRequest>
{
    public CreateAreaRequestValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty().WithMessage("Area name is required")
            .MaximumLength(150).WithMessage("Area name must not exceed 150 characters");

        RuleFor(x => x.City)
            .NotEmpty().WithMessage("City is required")
            .MaximumLength(100).WithMessage("City must not exceed 100 characters");

        RuleFor(x => x.Description)
            .MaximumLength(300).WithMessage("Description must not exceed 300 characters");
    }
}
