// Tipos de la base de datos.
// Cuando el schema esté estable, sustitúyelos por los tipos generados automáticamente:
//   npx supabase gen types typescript --project-id TU_PROJECT_ID > src/lib/supabase/types.ts

export type Database = {
  public: {
    Tables: {
      profiles: {
        Row: {
          id: string;
          display_name: string;
          bio: string | null;
          avatar_url: string | null;
          role: 'candidate' | 'company' | 'admin';
          is_public: boolean;
          created_at: string;
          updated_at: string;
        };
        Insert: Omit<Database['public']['Tables']['profiles']['Row'], 'created_at' | 'updated_at'>;
        Update: Partial<Database['public']['Tables']['profiles']['Insert']>;
      };
      skills: {
        Row: {
          id: string;
          slug: string;
          label: string;
          category: string;
          created_at: string;
        };
        Insert: Omit<Database['public']['Tables']['skills']['Row'], 'id' | 'created_at'>;
        Update: Partial<Database['public']['Tables']['skills']['Insert']>;
      };
      profile_skills: {
        Row: {
          profile_id: string;
          skill_id: string;
          level: 'beginner' | 'mid' | 'senior' | null;
          verified: boolean;
        };
        Insert: Database['public']['Tables']['profile_skills']['Row'];
        Update: Partial<Database['public']['Tables']['profile_skills']['Insert']>;
      };
      challenges: {
        Row: {
          id: string;
          skill_id: string | null;
          title: string;
          description: string | null;
          difficulty: 'easy' | 'medium' | 'hard';
          is_active: boolean;
          created_at: string;
        };
        Insert: Omit<Database['public']['Tables']['challenges']['Row'], 'id' | 'created_at'>;
        Update: Partial<Database['public']['Tables']['challenges']['Insert']>;
      };
      challenge_attempts: {
        Row: {
          id: string;
          profile_id: string;
          challenge_id: string;
          status: 'pending' | 'submitted' | 'passed' | 'failed';
          score: number | null;
          submitted_at: string | null;
          evaluated_at: string | null;
          created_at: string;
        };
        Insert: Omit<Database['public']['Tables']['challenge_attempts']['Row'], 'id' | 'created_at'>;
        Update: Partial<Database['public']['Tables']['challenge_attempts']['Insert']>;
      };
    };
  };
};
