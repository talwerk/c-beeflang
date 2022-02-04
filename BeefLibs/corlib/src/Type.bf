using System;
using System.Reflection;
using System.Collections;
using System.Diagnostics;

namespace System
{
    struct ClassVData
    {
        public Type mType;
        // The rest of this structured is generated by the compiler,
        //  including the vtable and interface slots
    }

    [Ordered, AlwaysInclude(AssumeInstantiated=true)]
    public class Type
    {
		extern const Type* sTypes;
		extern static int32 sTypeCount;

		protected const BindingFlags cDefaultLookup = BindingFlags.Instance | BindingFlags.Static | BindingFlags.Public;

		protected int32 mSize;
		protected TypeId mTypeId;
		protected TypeId mBoxedType;
		protected TypeFlags mTypeFlags;
		protected int32 mMemberDataOffset;
		protected TypeCode mTypeCode;
		protected uint8 mAlign;
		protected uint8 mAllocStackCountOverride;

		public static TypeId TypeIdEnd
		{
			get
			{
				return (.)sTypeCount;
			}
		}

		public static Enumerator Types
		{
			get
			{
				return .();
			}
		}

        public int32 Size
        {
            get
            {
                return mSize;
            }
        }

		public int32 Align
		{
		    get
		    {
		        return mAlign;
		    }
		}

		public int32 Stride
		{
		    get
		    {
		        return Math.Align(mSize, mAlign);
		    }
		}

		public TypeId TypeId
		{
			get
			{
				return mTypeId;
			}
		}

        public bool IsPrimitive
        {
            get
            {
                return (mTypeFlags & TypeFlags.Primitive) != 0;
            }
        }

		public bool IsInteger
		{
			get
			{
				switch (mTypeCode)
				{
				case .Int8,
					 .Int16,
					 .Int32,
					 .Int64,
					 .Int,
					 .UInt8,
					 .UInt16,
					 .UInt32,
					 .UInt64,
					 .UInt:
					return true;
				default:
					return false;
				}
			}
		}

		public bool IsIntegral
		{
			get
			{
				switch (mTypeCode)
				{
				case .Int8,
					 .Int16,
					 .Int32,
					 .Int64,
					 .Int,
					 .UInt8,
					 .UInt16,
					 .UInt32,
					 .UInt64,
					 .UInt,
					 .Char8,
					 .Char16,
					 .Char32:
					return true;
				default:
					return false;
				}
			}
		}

		public bool IsFloatingPoint
		{
			get
			{
				switch (mTypeCode)
				{
				case .Float,
					 .Double:
					return true;
				default:
					return false;
				}
			}
		}

		public bool IsSigned
		{
			get
			{
				switch (mTypeCode)
				{
				case .Int8,
					 .Int16,
					 .Int32,
					 .Int64,
					 .Float,
					 .Double:
					return true;
				default:
					return false;
				}
			}
		}

		public bool IsChar
		{
			get
			{
				switch (mTypeCode)
				{
				case .Char8,
					 .Char16,
					 .Char32:
					return true;
				default:
					return false;
				}
			}
		}

		public bool IsTypedPrimitive
		{
		    get
		    {
		        return (mTypeFlags & TypeFlags.TypedPrimitive) != 0;
		    }
		}

		public bool IsArray
		{
			get
			{
				return (mTypeFlags & TypeFlags.Array) != 0;
			}
		}

		public bool IsSizedArray
		{
			get
			{
				return (mTypeFlags & TypeFlags.SizedArray) != 0;
			}
		}

		public bool IsConstExpr
		{
			get
			{
				return (mTypeFlags & TypeFlags.ConstExpr) != 0;
			}
		}

		public bool IsObject
		{
		    get
		    {
		        return (mTypeFlags & TypeFlags.Object) != 0;
		    }
		}

		public bool IsInterface
		{
		    get
		    {
		        return (mTypeFlags & TypeFlags.Interface) != 0;
		    }
		}

		public bool IsValueType
		{
		    get
		    {
		        return (mTypeFlags & (.Struct | .Primitive | .TypedPrimitive)) != 0;
		    }
		}

        public bool IsStruct
        {
            get
            {
                return (mTypeFlags & TypeFlags.Struct) != 0;
            }
        }

		public bool IsSplattable
		{
		    get
		    {
		        return (mTypeFlags & TypeFlags.Splattable) != 0;
		    }
		}

		public bool IsUnion
		{
		    get
		    {
		        return (mTypeFlags & TypeFlags.Union) != 0;
		    }
		}

		public bool IsPointer
		{
		    get
		    {
		        return (mTypeFlags & (TypeFlags.Boxed | TypeFlags.Pointer)) == TypeFlags.Pointer;
		    }
		}

        public bool IsBoxed
        {
            get
            {
                return (mTypeFlags & TypeFlags.Boxed) != 0;
            }
        }

		public bool IsBoxedStructPtr
		{
		    get
		    {
		        return (mTypeFlags & (TypeFlags.Boxed | TypeFlags.Pointer)) == TypeFlags.Boxed | TypeFlags.Pointer;
		    }
		}

		public bool IsBoxedPrimitivePtr
		{
			get
			{
				if (!mTypeFlags.HasFlag(.Boxed))
					return false;

				let underyingType = UnderlyingType;
				if (var genericTypeInstance = underyingType as SpecializedGenericType)
				{
					if (genericTypeInstance.UnspecializedType == typeof(Pointer<>))
						return true;
				}

				return false;
			}
		}

		public Type BoxedPtrType
		{
			get
			{
				if (!mTypeFlags.HasFlag(.Boxed))
					return null;

				if (mTypeFlags.HasFlag(.Pointer))
				{
					return UnderlyingType;
				}

				let underyingType = UnderlyingType;
				if (var genericTypeInstance = underyingType as SpecializedGenericType)
				{
					if (genericTypeInstance.UnspecializedType == typeof(Pointer<>))
						return genericTypeInstance.GetGenericArg(0);
				}

				return null;
			}
		}

		public TypeInstance BoxedType
		{
			get
			{
				return (TypeInstance)GetType(mBoxedType);
			}
		}

		public bool IsEnum
		{
		    get
		    {
				return mTypeCode == TypeCode.Enum;
		    }
		}

		public bool IsTuple
		{
			get
			{
				return mTypeFlags.HasFlag(TypeFlags.Tuple);
			}
		}

		public bool IsNullable
		{
			get
			{
				return mTypeFlags.HasFlag(.Nullable);
			}
		}

		public bool WantsMark
		{
		    get
		    {
		        return (mTypeFlags & .WantsMark) != 0;
		    }
		}

		public bool HasDestructor
		{
		    get
		    {
		        return (mTypeFlags & .HasDestructor) != 0;
		    }
		}

		public bool IsGenericType
		{
		    get
		    {
		        return (mTypeFlags & (.SpecializedGeneric | .UnspecializedGeneric)) != 0;
		    }
		}

		public bool IsGenericParam
		{
		    get
		    {
		        return (mTypeFlags & .GenericParam) != 0;
		    }
		}

		public virtual int32 GenericParamCount
		{
			get
			{
				return 0;
			}
		}

		public virtual int32 InstanceSize
		{
		    get
		    {
		        return mSize;
		    }
		}

		public virtual int32 InstanceAlign
		{
		    get
		    {
		        return mAlign;
		    }
		}

		public virtual int32 InstanceStride
		{
		    get
		    {
		        return Math.Align(mSize, mAlign);
		    }
		}

		public virtual TypeInstance BaseType
		{
		    get
		    {
		        return null;
		    }
		}

		public virtual TypeInstance.InterfaceEnumerator Interfaces
		{
		    get
		    {
		        return .(null);
		    }
		}

		public virtual TypeInstance OuterType
		{
		    get
		    {
		        return null;
		    }
		}

		public virtual Type UnderlyingType
		{
		    get
		    {
		        return null;
		    }
		}

		public virtual int32 FieldCount
		{
			get
			{
				return 0;
			}
		}

		public virtual int32 MinValue
		{
			[Error("This property can only be accessed directly from a typeof() expression")]
			get
			{
				return 0;
			}
		}

		public virtual int32 MaxValue
		{
			[Error("This property can only be accessed directly from a typeof() expression")]
			get
			{
				return 0;
			}
		}

        public int32 GetTypeId()
        {
            return (int32)mTypeId;
        }

		static extern Type Comptime_GetTypeById(int32 typeId);
		static extern Type Comptime_GetTypeByName(StringView name);
		static extern String Comptime_Type_ToString(int32 typeId);
		static extern Type Comptime_GetSpecializedType(Type unspecializedType, Span<Type> typeArgs);
		static extern bool Comptime_Type_GetCustomAttribute(int32 typeId, int32 attributeId, void* dataPtr);
		static extern int32 Comptime_GetMethodCount(int32 typeId);
		static extern int64 Comptime_GetMethod(int32 typeId, int32 methodIdx);
		static extern String Comptime_Method_ToString(int64 methodHandle);
		static extern String Comptime_Method_GetName(int64 methodHandle);
		static extern ComptimeMethodInfo.Info Comptime_Method_GetInfo(int64 methodHandle);
		static extern ComptimeMethodInfo.ParamInfo Comptime_Method_GetParamInfo(int64 methodHandle, int32 paramIdx);

        protected static Type GetType(TypeId typeId)
        {
			if (Compiler.IsComptime)
				return Comptime_GetTypeById((.)typeId);
            return sTypes[(int32)typeId];
        }

		protected static Type GetType_(int32 typeId)
		{
			if (Compiler.IsComptime)
				return Comptime_GetTypeById(typeId);
		    return sTypes[typeId];
		}

		public static Result<Type> GetTypeByName(StringView typeName)
		{
			if (Compiler.IsComptime)
			{
				var type = Comptime_GetTypeByName(typeName);
				if (type == null)
					return .Err;
				return type;
			}

			return .Err;
		}

		void GetBasicName(String strBuffer)
		{
			switch (mTypeCode)
			{
			case .None: strBuffer.Append("void");
			case .CharPtr: strBuffer.Append("char8*");
			case .Pointer: strBuffer.Append("void*");
			case .NullPtr: strBuffer.Append("void*");
			case .Var: strBuffer.Append("var");
			case .Let: strBuffer.Append("let");
			case .Boolean: strBuffer.Append("bool");
			case .Int8: strBuffer.Append("int8");
			case .UInt8: strBuffer.Append("uint8");
			case .Int16: strBuffer.Append("int16");
			case .UInt16: strBuffer.Append("uint16");
			case .Int32: strBuffer.Append("int32");
			case .UInt32: strBuffer.Append("uint32");
			case .Int64: strBuffer.Append("int64");
			case .UInt64: strBuffer.Append("uint64");
			case .Int: strBuffer.Append("int");
			case .UInt: strBuffer.Append("uint");
			case .Char8: strBuffer.Append("char8");
			case .Char16: strBuffer.Append("char16");
			case .Char32: strBuffer.Append("char32");
			case .Float: strBuffer.Append("float");
			case .Double: strBuffer.Append("double");
			default: ((int32)mTypeCode).ToString(strBuffer);
			}
		}

		void ComptimeToString(String strBuffer)
		{
			if (Compiler.IsComptime)
				strBuffer.Append(Comptime_Type_ToString((.)mTypeId));
		}

        public virtual void GetFullName(String strBuffer)
        {
			GetBasicName(strBuffer);
        }

        public virtual void GetName(String strBuffer)
        {
            GetBasicName(strBuffer);
        }

		// Putting this in causes sTypes to be required when Object.ToString is reified
        /*public override void ToString(String strBuffer)
        {
			GetFullName(strBuffer);
        }*/
        
        protected this()
        {
        }

        public virtual bool IsSubtypeOf(Type type)
        {
            return type == this;
        }

		public virtual Result<FieldInfo> GetField(String fieldName)
		{
		    return .Err;
		}

		public virtual Result<FieldInfo> GetField(int idx)
		{
		    return .Err;
		}

		public virtual FieldInfo.Enumerator GetFields(BindingFlags bindingFlags = cDefaultLookup)
		{
		    return FieldInfo.Enumerator(null, bindingFlags);
		}

		public bool HasCustomAttribute<T>() where T : Attribute
		{
			if (Compiler.IsComptime)
			{
				return Comptime_Type_GetCustomAttribute((int32)TypeId, (.)typeof(T).TypeId, null);
			}

			if (var typeInstance = this as TypeInstance)
				return typeInstance.[Friend]HasCustomAttribute<T>(typeInstance.[Friend]mCustomAttributesIdx);
			return false;
		}

		public Result<T> GetCustomAttribute<T>() where T : Attribute
		{
			if (Compiler.IsComptime)
			{
				T val = ?;
				if (Comptime_Type_GetCustomAttribute((int32)TypeId, (.)typeof(T).TypeId, &val))
					return val;
				return .Err;
			}

			if (var typeInstance = this as TypeInstance)
				return typeInstance.[Friend]GetCustomAttribute<T>(typeInstance.[Friend]mCustomAttributesIdx);
			return .Err;
		}

		public override void ToString(String strBuffer)
		{
			GetFullName(strBuffer);
		}

		public struct Enumerator : IEnumerator<Type>
		{
			int32 mCurId;

			public Result<Type> GetNext() mut
			{
				while (true)
				{
					if (Compiler.IsComptime)
						Runtime.FatalError("Comptime type enumeration not supported");

					if (mCurId >= sTypeCount)
						return .Err;
					let type = sTypes[mCurId++];
					if (type != null)
						return .Ok(type);
				}
			}
		}	
    }



    enum TypeCode : uint8
	{   
	    None,
	    CharPtr,
		StringId,
	    Pointer,
	    NullPtr,
		Self,
		Dot,
	    Var,
		Let,
	    Boolean,
	    Int8,
		UInt8,
		Int16,
		UInt16,
		Int24,
		UInt24,
		Int32,
		UInt32,
		Int40,
		UInt40,
		Int48,
		UInt48,
		Int56,
		UInt56,
		Int64,
		UInt64,
		Int128,
		UInt128,
	    Int,
	    UInt,
		IntUnknown,
		UIntUnknown,
	    Char8,
		Char16,
	    Char32,
	    Float,
	    Double,
		Float2,
	    Object,
	    Interface,
	    Struct,
	    Enum,
		TypeAlias,
		Extension,
		FloatX2,
		FloatX3,
		FloatX4,
		DoubleX2,
		DoubleX3,
		DoubleX4,
		Int64X2,
		Int64X3,
		Int64X4,
	}
}

namespace System.Reflection
{
    public struct TypeId : int32 {}

    [Ordered, AlwaysInclude(AssumeInstantiated=true)]
    public class TypeInstance : Type
    {
        [CRepr, AlwaysInclude]
        public struct FieldData
        {
            public String mName;
			public TypeId mFieldTypeId;
            public int mData;
#if BF_32_BIT
			public int mDataHi;
#endif
            public FieldFlags mFlags;
            public int32 mCustomAttributesIdx;
        }

		// This is only valid if there is no FieldData on a splattable struct
		[CRepr, AlwaysInclude]
		public struct FieldSplatData
		{
			public TypeId[3] mSplatTypes;
			public int32[3] mSplatOffsets;
		}

        [CRepr, AlwaysInclude]
        public struct MethodData
        {
            public String mName; // mName
            public void* mFuncPtr;
			public ParamData* mParamData;
			public TypeId mReturnType;
			public int16 mParamCount;
			public MethodFlags mFlags;
			public int32 mMethodIdx;
			public int32 mVirtualIdx;
			public int32 mCustomAttributesIdx;
			public int32 mReturnCustomAttributesIdx;
        }

		public enum ParamFlags : int16
		{
			None = 0,
			Splat = 1,
			Implicit = 2,
			AppendIdx = 4
		}

		[CRepr, AlwaysInclude]
		public struct ParamData
		{
			public String mName;
			public TypeId mType;
			public ParamFlags mParamFlags;
			public int32 mDefaultIdx;
			public int32 mCustomAttributesIdx;
		}

		public struct InterfaceData
		{
			public TypeId mInterfaceType;
			public int32 mStartInterfaceTableIdx;
			public int32 mStartVirtualIdx;
		}

		public struct InterfaceEnumerator : IEnumerator<TypeInstance>
		{
			public TypeInstance mTypeInstance;
			public int mIdx = -1;

			public this(TypeInstance typeInstance)
			{
				mTypeInstance = typeInstance;
			}

			public Result<TypeInstance> GetNext() mut
			{
				if (mTypeInstance == null)
					return .Err;
				mIdx++;
				if (mIdx >= mTypeInstance.mInterfaceCount)
					return .Err;
				return Type.[Friend]GetType(mTypeInstance.mInterfaceDataPtr[mIdx].mInterfaceType) as TypeInstance;
			}
		}

        ClassVData* mTypeClassVData;
        String mName;
        String mNamespace;
        int32 mInstSize;
        int32 mInstAlign;
		int32 mCustomAttributesIdx;
        TypeId mBaseType;
        TypeId mUnderlyingType;
		TypeId mOuterType;		
		int32 mInheritanceId;
		int32 mInheritanceCount;

		uint8 mInterfaceSlot;
        uint8 mInterfaceCount;
		int16 mInterfaceMethodCount;
        int16 mMethodDataCount;
        int16 mPropertyDataCount;
        int16 mFieldDataCount;

        InterfaceData* mInterfaceDataPtr;
		void** mInterfaceMethodTable;
		MethodData* mMethodDataPtr;
		void* mPropertyDataPtr;
		FieldData* mFieldDataPtr;
		void** mCustomAttrDataPtr;

        public override int32 InstanceSize
        {
            get
            {
                return mInstSize;
            }
        }

		public override int32 InstanceAlign
		{
		    get
		    {
		        return mInstAlign;
		    }
		}

		public override int32 InstanceStride
		{
		    get
		    {
		        return Math.Align(mInstSize, mInstAlign);
		    }
		}

        public override TypeInstance BaseType
        {
            get
            {
                return (TypeInstance)Type.GetType(mBaseType);
            }
        }

		public override InterfaceEnumerator Interfaces
		{
		    get
		    {
		        return .(this);
		    }
		}

		public override TypeInstance OuterType
		{
		    get
		    {
		        return (TypeInstance)Type.GetType(mOuterType);
		    }
		}

		public override Type UnderlyingType
		{
		    get
		    {
		        return Type.GetType(mUnderlyingType);
		    }
		}

		public override int32 FieldCount
		{
			get
			{
				return mFieldDataCount;
			}
		}

        public override bool IsSubtypeOf(Type checkBaseType)
		{
		    TypeInstance curType = this;
			if (curType.IsBoxed)
			{
				curType = curType.UnderlyingType as TypeInstance;
				if (curType == null)
					return false;
			}
		    while (true)
		    {
		        if (curType == checkBaseType)
		            return true;
		        if (curType.mBaseType == 0)
		            return false;
		        curType = (TypeInstance)Type.GetType(curType.mBaseType);
		    }
		}

        public override void GetFullName(String strBuffer)
        {
			if (mTypeFlags.HasFlag(TypeFlags.Tuple))
			{
				strBuffer.Append('(');
				if (mFieldDataCount > 0)
				{
					for (int fieldIdx < mFieldDataCount)
					{
						if (fieldIdx > 0)
							strBuffer.Append(", ");
						GetType(mFieldDataPtr[fieldIdx].[Friend]mFieldTypeId).GetFullName(strBuffer);
					}
				}
				else if ((mTypeFlags.HasFlag(.Splattable)) && (mFieldDataPtr != null))
				{
					let splatData = (FieldSplatData*)mFieldDataPtr;
					for (int i < 3)
					{
						if (splatData.mSplatTypes[i] == 0)
							break;
						if (i > 0)
							strBuffer.Append(", ");
						GetType(splatData.mSplatTypes[i]).GetFullName(strBuffer);
					}
				}
				strBuffer.Append(')');
			}
			else if (mTypeFlags.HasFlag(.Boxed))
			{
				strBuffer.Append("boxed ");
				let ut = UnderlyingType;
				ut.GetFullName(strBuffer);
			}
			else
			{
				if ((mName != null) && (mName != ""))
				{
					if (mOuterType != 0)
					{
						let outerType = GetType(mOuterType);
						if (outerType != null)
							outerType.GetFullName(strBuffer);
						else
							strBuffer.Append("???");
						strBuffer.Append(".");
					}
					else
					{
						if (!String.IsNullOrEmpty(mNamespace))
					    	strBuffer.Append(mNamespace, ".");
					}

					strBuffer.Append(mName);
				}
				else if (mTypeFlags.HasFlag(.Delegate))
					strBuffer.Append("delegate");
				else if (mTypeFlags.HasFlag(.Function))
					strBuffer.Append("function");
				else if (mBaseType != 0)
				{
					strBuffer.Append("derivative of ");
					GetType(mBaseType).GetFullName(strBuffer);
				}
			}
        }

        public override void GetName(String strBuffer)
        {
            strBuffer.Append(mName);
        }

		public override Result<FieldInfo> GetField(String fieldName)
		{
		    for (int32 i = 0; i < mFieldDataCount; i++)
		    {
		        FieldData* fieldData = &mFieldDataPtr[i];
		        if (fieldData.[Friend]mName == fieldName)
		            return FieldInfo(this, fieldData);
		    }
			var baseType = BaseType;
			if (baseType != null)
				return baseType.GetField(fieldName);
		    return .Err;
		}

		public override Result<FieldInfo> GetField(int fieldIdx)
		{
			if ((fieldIdx < 0) || (fieldIdx >= mFieldDataCount))
				return .Err;
			return FieldInfo(this, &mFieldDataPtr[fieldIdx]);
		}

		public override FieldInfo.Enumerator GetFields(BindingFlags bindingFlags = cDefaultLookup)
		{
		    return FieldInfo.Enumerator(this, bindingFlags);
		}

		bool HasCustomAttribute<T>(int customAttributeIdx) where T : Attribute
		{
			if (customAttributeIdx == -1)
			    return false;

			void* data = mCustomAttrDataPtr[customAttributeIdx];
			return AttributeInfo.HasCustomAttribute(data, typeof(T));
		}

		Result<T> GetCustomAttribute<T>(int customAttributeIdx) where T : Attribute
		{
			if (customAttributeIdx == -1)
			    return .Err;

			void* data = mCustomAttrDataPtr[customAttributeIdx];

			T attrInst = ?;
			switch (AttributeInfo.GetCustomAttribute(data, typeof(T), &attrInst))
			{
			case .Ok: return .Ok(attrInst);
			default:
				return .Err;
			}
		}
    }

	[Ordered, AlwaysInclude(AssumeInstantiated=true)]
	class PointerType : Type
	{
		TypeId mElementType;

		public override Type UnderlyingType
		{
			get
			{
				return Type.GetType(mElementType);
			}
		}

		public override void GetFullName(String strBuffer)
		{
			UnderlyingType.GetFullName(strBuffer);
			strBuffer.Append("*");
		}
	}

	[Ordered, AlwaysInclude(AssumeInstantiated=true)]
	class RefType : Type
	{
		public enum RefKind
		{
			Ref,
			Out,
			Mut
		}

		TypeId mElementType;
		RefKind mRefKind;

		public RefKind RefKind => mRefKind;

		public override Type UnderlyingType
		{
			get
			{
				return Type.GetType(mElementType);
			}
		}

		public override void GetFullName(String strBuffer)
		{
			switch (mRefKind)
			{
			case .Ref: strBuffer.Append("ref ");
			case .Out: strBuffer.Append("out ");
			case .Mut: strBuffer.Append("mut ");
			}

			UnderlyingType.GetFullName(strBuffer);
		}
	}

	[Ordered, AlwaysInclude(AssumeInstantiated=true)]
	class SizedArrayType : Type
	{
	    TypeId mElementType;
		int32 mElementCount;

		public override Type UnderlyingType
		{
			get
			{
				return Type.GetType(mElementType);
			}
		}

		public int ElementCount
		{
			get
			{
				return mElementCount;
			}
		}

		public override void GetFullName(String strBuffer)
		{
			UnderlyingType.GetFullName(strBuffer);
			strBuffer.Append("[");
			mElementCount.ToString(strBuffer);
			strBuffer.Append("]");
		}
	}

	[Ordered, AlwaysInclude(AssumeInstantiated=true)]
	class ConstExprType : Type
	{
	    TypeId mValueType;
		int64 mValue;

		public Type ValueType
		{
			get
			{
				return Type.GetType(mValueType);
			}
		}

		public ref int64 ValueData
		{
			get
			{
				return ref mValue;
			}
		}

		public override void GetFullName(String strBuffer)
		{
			strBuffer.Append("const ");
			switch (GetType(mValueType))
			{
			case typeof(float):
				(*(float*)&mValue).ToString(strBuffer);
			case typeof(double):
				(*(double*)&mValue).ToString(strBuffer);
			case typeof (bool):
				strBuffer.Append((*(bool*)&mValue) ? "true" : "false");
			case typeof(char8), typeof(char16), typeof(char32):
				strBuffer.Append('\'');
				var str = (*(char32*)&mValue).ToString(.. scope .());
				let len = str.Length;
				String.QuoteString(&str[0], len, str);
				strBuffer.Append(str[(len + 1)...^2]);
				strBuffer.Append('\'');
			case typeof(uint64), typeof(uint):
				(*(uint64*)&mValue).ToString(strBuffer);
			default:
				mValue.ToString(strBuffer);
			}
		}
	}

    [Ordered, AlwaysInclude(AssumeInstantiated=true)]
    class UnspecializedGenericType : TypeInstance
    {
        [CRepr, AlwaysInclude]
        struct GenericParam
        {
            String mName;
        }

        uint8 mGenericParamCount;

		public Result<Type> GetSpecializedType(params Span<Type> typeArgs)
		{
			if (Compiler.IsComptime)
			{
				 var specializedType = Type.[Friend]Comptime_GetSpecializedType(this, typeArgs);
				if (specializedType != null)
					return specializedType;
			}
			return .Err;
		}
    }

    // Only for resolved types
    [Ordered, AlwaysInclude(AssumeInstantiated=true)]
    class SpecializedGenericType : TypeInstance
    {
        protected TypeId mUnspecializedType;
        protected TypeId* mResolvedTypeRefs;

		public Type UnspecializedType
		{
			get
			{
				return Type.GetType(mUnspecializedType);
			}
		}

		public override int32 GenericParamCount
		{
			get
			{
				var unspecializedTypeG = Type.GetType(mUnspecializedType);
				var unspecializedType = (UnspecializedGenericType)unspecializedTypeG;
				return unspecializedType.[Friend]mGenericParamCount;
			}
		}

		public Type GetGenericArg(int argIdx)
		{
			return Type.GetType(mResolvedTypeRefs[argIdx]);
		}

		public override void GetFullName(String strBuffer)
		{
			var unspecializedTypeG = Type.GetType(mUnspecializedType);
			var unspecializedType = (UnspecializedGenericType)unspecializedTypeG;
			base.GetFullName(strBuffer);

			int32 outerGenericCount = 0;
			var outerType = OuterType;
			if (outerType != null)
				outerGenericCount = outerType.GenericParamCount;

			if (outerGenericCount < unspecializedType.[Friend]mGenericParamCount)
			{
				strBuffer.Append('<');
				for (int i = outerGenericCount; i < unspecializedType.[Friend]mGenericParamCount; i++)
				{
					if (i > 0)
						strBuffer.Append(", ");
					Type.GetType(mResolvedTypeRefs[i]).GetFullName(strBuffer);
				}
				strBuffer.Append('>');
			}
		}
    }

    [Ordered, AlwaysInclude(AssumeInstantiated=true)]
    class ArrayType : SpecializedGenericType
    {
        int32 mElementSize;
        uint8 mRank;
        uint8 mElementsDataOffset;

		public override void GetFullName(String strBuffer)
		{
			Type.GetType(mResolvedTypeRefs[0]).GetFullName(strBuffer);
			strBuffer.Append('[');
			for (int commaNum < mRank - 1)
				strBuffer.Append(',');
			strBuffer.Append(']');
		}

		public Result<Object> CreateObject(int32 count)
		{
			if ([Friend]mTypeClassVData == null)
				return .Err;

			Object obj;

			let genericType = GetGenericArg(0);
			let arraySize = [Friend]mInstSize - genericType.Size + genericType.Stride * count;
#if BF_ENABLE_OBJECT_DEBUG_FLAGS
			int32 stackCount = Compiler.Options.AllocStackCount;
			if (mAllocStackCountOverride != 0)
				stackCount = mAllocStackCountOverride;
			obj = Internal.Dbg_ObjectAlloc([Friend]mTypeClassVData, arraySize, [Friend]mInstAlign, stackCount);
#else
			void* mem = new [Align(16)] uint8[arraySize]* (?);
			obj = Internal.UnsafeCastToObject(mem);
			obj.[Friend]mClassVData = (.)(void*)[Friend]mTypeClassVData;
#endif
			//Array1 holds the first element, we only want to set the remaining elements
			if(count > 1)
				Internal.MemSet((uint8*)Internal.UnsafeCastToPtr(obj) + [Friend]mInstSize, 0, [Friend]arraySize - [Friend]mInstSize);
			var array = (Array)obj;
			array.[Friend]mLength = count;
			return obj;
		}
    }

	[Ordered, AlwaysInclude(AssumeInstantiated=true)]
	class GenericParamType : Type
	{
		public override void GetName(String strBuffer)
		{
			if (Compiler.IsComptime)
				this.[Friend]ComptimeToString(strBuffer);
			else
				strBuffer.Append("$GenericParam");
		}

		public override void GetFullName(String strBuffer)
		{
			GetName(strBuffer);
		}
	}

    public enum TypeFlags : uint32
    {
        UnspecializedGeneric    = 0x0001,
        SpecializedGeneric      = 0x0002,
        Array                   = 0x0004,

        Object                  = 0x0008,
        Boxed                   = 0x0010,
        Pointer                 = 0x0020,
        Struct                  = 0x0040,
		Interface               = 0x0080,
        Primitive               = 0x0100,
		TypedPrimitive          = 0x0200,
		Tuple					= 0x0400,
		Nullable				= 0x0800,
		SizedArray				= 0x1000,
		Splattable				= 0x2000,
		Union					= 0x4000,
		ConstExpr				= 0x8000,
		//
		WantsMark				= 0x10000,
		Delegate				= 0x20000,
		Function				= 0x40000,
		HasDestructor			= 0x80000,
		GenericParam			= 0x100000,
    }

    public enum FieldFlags : uint16
    {
        // member access mask - Use this mask to retrieve accessibility information.
        FieldAccessMask         = 0x0007,
        PrivateScope            = 0x0000,    // Member not referenceable.
        Private                 = 0x0001,    // Accessible only by the parent type.  
        FamAndProject           = 0x0002,    // Accessible by sub-types only in this Assembly.
        Project                 = 0x0003,    // Accessibly by anyone in the Assembly.
        Family                  = 0x0004,    // Accessible only by type and sub-types.    
        FamOrProject            = 0x0005,    // Accessibly by sub-types anywhere, plus anyone in assembly.
        Public                  = 0x0006,    // Accessibly by anyone who has visibility to this scope.    
        // end member access mask
    
        // field contract attributes.
        Static                  = 0x0010,     // Defined on type, else per instance.
        InitOnly                = 0x0020,     // Field may only be initialized, not written to after init.
        Const                   = 0x0040,     // Value is compile time constant.
        SpecialName             = 0x0080,     // field is special.  Name describes how.
        EnumPayload				= 0x0100,
		EnumDiscriminator		= 0x0200,
		EnumCase				= 0x0400
    }

	public enum MethodFlags : uint16
	{
		MethodAccessMask    	=  0x0007,
		PrivateScope        	=  0x0000,     // Member not referenceable.
		Private             	=  0x0001,     // Accessible only by the parent type.  
		FamANDAssem         	=  0x0002,     // Accessible by sub-types only in this Assembly.
		Assembly            	=  0x0003,     // Accessibly by anyone in the Assembly.
		Family              	=  0x0004,     // Accessible only by type and sub-types.    
		FamORAssem          	=  0x0005,     // Accessibly by sub-types anywhere, plus anyone in assembly.
		Public              	=  0x0006,     // Accessibly by anyone who has visibility to this scope.    
		// end member access mask

		// method contract attributes.
		Static              	=  0x0010,     // Defined on type, else per instance.
		Final               	=  0x0020,     // Method may not be overridden.
		Virtual             	=  0x0040,     // Method virtual.
		HideBySig           	=  0x0080,     // Method hides by name+sig, else just by name.
		CheckAccessOnOverride	=  0x0200,

		// vtable layout mask - Use this mask to retrieve vtable attributes.
		VtableLayoutMask    	=  0x0100,
#unwarn
		ReuseSlot           	=  0x0000,     // The default.
#unwarn
		NewSlot             	=  0x0100,     // Method always gets a new slot in the vtable.
		// end vtable layout mask

		// method implementation attributes.
		Abstract            	=  0x0400,     // Method does not provide an implementation.
		SpecialName         	=  0x0800,     // Method is special.  Name describes how.
		StdCall					=  0x1000,
		FastCall				=  0x2000,
		ThisCall				=  0x3000, // Purposely resuing StdCall|FastCall
		Mutating				=  0x4000,
		Constructor				=  0x8000,
	}
}
