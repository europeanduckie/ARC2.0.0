# ARC Framework
Version 2.0.1

LICENSED UNDER MIT

# API Reference

## Framework.Run(): Framework
### This function creates or returns an existing instance of the framework.

## Framework:GetModule(x: string): ()
### This function returns a module stored inside of the framework.

## Framework:GetPackage(x: string): ()
### This function returns a package stored inside of the framework.

## Framework:GetComponent(x: string): ()
### This function returns a component stored inside of the framework.

## Framework:RequirePackages(Directory: Instance): ()
### This function requires packages inside a Directory.

## Framework:RequireComponents(Directory: Instance): ()
### This function requires components inside a Directory.

## Framework:RequireModules(Directory: Instance): ()
### This function requires modules inside a Directory.

## Framework:Init(): ()
### Initializes every module which was required earlier.

## Framework:Start(): ()
### Starts every module which was required and initialized earlier.

## Framework:Stop(): ()
### Stops and cleans up the previous instance of the framework.