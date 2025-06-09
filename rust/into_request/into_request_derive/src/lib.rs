extern crate proc_macro2;
extern crate quote;
extern crate syn;

extern crate proc_macro;

use proc_macro::TokenStream;
use quote::quote;
use syn::{parse::{Parse, ParseStream}, parse_macro_input, Data, DeriveInput, LitStr, Meta, Token};

#[proc_macro_derive(IntoRequest, attributes(endpoint, method))]
pub fn derive_into_request(input: TokenStream) -> TokenStream {
    // Parse the input tokens into a syntax tree
    let ast = parse_macro_input!(input as DeriveInput);

    // Extract the endpoint attribute from the enum attributes
    let endpoint = match extract_single_attr(&ast.attrs, "endpoint") {
        Ok(value) => value,
        Err(err) => return err.to_compile_error().into(),
    };

    // Ensure we are working on an enum.
    let enum_data = match ast.data {
        Data::Enum(data) => data,
        _ => {
            return syn::Error::new_spanned(
                ast.ident,
                "IntoRequest can only be derived for enums",
            )
            .to_compile_error()
            .into();
        }
    };

    // Create match arms for each variant. We assume each variant has a #[method("...")] attribute.
    let variant_arms = enum_data.variants.iter().map(|variant| {
        let method = match extract_single_attr(&variant.attrs, "method") {
            Ok(method_str) => method_str,
            Err(err) => return err.to_compile_error(),
        };

        // Create a pattern that matches any fields (named or unnamed) for the variant.
        
        let variant_ident = &variant.ident;
        quote! {
            Self::#variant_ident { .. } => reqwest::Method::from_bytes(#method.as_bytes()).unwrap(),
        }
    });

    let ident = ast.ident;

    let gene = quote! {
        impl IntoRequest for #ident {
            const ENDPOINT: &'static str = #endpoint;

            fn get_method(&self) -> reqwest::Method {
                match self {
                    #(#variant_arms)*
                    // Optionally, you could add a fallback case:
                    //_ => unreachable!(),
                }
            }
        }
    };

    gene.into()
}

/// Helper function to extract an attribute with a single string literal value.
/// It searches for an attribute with the given ident and returns the string literal.
fn extract_single_attr(attrs: &[syn::Attribute], attr_name: &str) -> Result<proc_macro2::TokenStream, syn::Error> {
    for attr in attrs {
        
        if attr.path().is_ident(attr_name) {           
            
            if let Meta::List(meta_list) = &attr.meta {
                let parsed: MyParser = meta_list.parse_args().unwrap();
                
                if let Some(lit_str) = parsed.v.first() {
                    // We return the literal as a token stream so that it can be injected as a literal.
                    return Ok(quote! { #lit_str });
                }
            }
        }
    }
    Err(syn::Error::new_spanned(
        &attrs[0],
        format!("Expected attribute `{}` with a string literal", attr_name),
    ))
}


struct MyParser {
    v: Vec<String>,
}

impl Parse for MyParser {
    #[inline]
    fn parse(input: ParseStream) -> Result<Self, syn::Error> {
        let mut v: Vec<String> = vec![];

        loop {
            if input.is_empty() {
                break;
            }

            v.push(input.parse::<LitStr>()?.value());

            if input.is_empty() {
                break;
            }

            input.parse::<Token!(,)>()?;
        }

        Ok(MyParser {
            v,
        })
    }
}